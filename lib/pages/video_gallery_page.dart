import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class VideoGalleryPage extends StatelessWidget {
  const VideoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final theme = Theme.of(context);

    return StreamBuilder<List<Video>>(
      stream: db.watchAllVideos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final videos = snapshot.data!;

        if (videos.isEmpty) {
          return _buildEmptyState(theme);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _VideoCard(video: video);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('Žiadne videá v trezore', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;
  const _VideoCard({required this.video});

  String _formatDate(DateTime date) => "${date.day}.${date.month}.${date.year}";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = Provider.of<AppDatabase>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => _playVideo(context, video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatúra (keďže sú šifrované, použijeme pekný placeholder)
            Expanded(
              child: Container(
                width: double.infinity,
                color: theme.colorScheme.secondaryContainer,
                child: Icon(Icons.play_circle_outline, size: 48, color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Video #${video.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatDate(video.createdAt), style: theme.textTheme.bodySmall),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                    onPressed: () => _confirmDelete(context, db, video),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EncryptedVideoPlayer(video: video)),
    );
  }

  void _confirmDelete(BuildContext context, AppDatabase db, Video video) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zmazať video?'),
        content: const Text('Tento súbor bude natrvalo odstránený.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zrušiť')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Zmazať', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final file = File(video.filePath);
      if (await file.exists()) await file.delete();
      await db.deleteVideo(video.filePath);
    }
  }
}

/// Špeciálny widget na prehrávanie dešifrovaného videa
class EncryptedVideoPlayer extends StatefulWidget {
  final Video video;
  const EncryptedVideoPlayer({super.key, required this.video});

  @override
  State<EncryptedVideoPlayer> createState() => _EncryptedVideoPlayerState();
}

class _EncryptedVideoPlayerState extends State<EncryptedVideoPlayer> {
  VideoPlayerController? _controller;
  File? _tempFile;
  bool _isDecrypting = true;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    try {
      // 1. Dešifrovanie do RAM
      final encryptedFile = File(widget.video.filePath);
      final encryptedBytes = await encryptedFile.readAsBytes();
      final decryptedBytes = await CryptoService.decryptBytes(encryptedBytes);

      // 2. Dočasné uloženie (VideoPlayer potrebuje cestu k súboru)
      final tempDir = await getTemporaryDirectory();
      _tempFile = File('${tempDir.path}/temp_preview.mp4');
      await _tempFile!.writeAsBytes(decryptedBytes);

      // 3. Inicializácia prehrávača
      _controller = VideoPlayerController.file(_tempFile!)
        ..initialize().then((_) {
          setState(() {
            _isDecrypting = false;
            _controller!.play();
          });
        });
    } catch (e) {
      debugPrint("Chyba pri dešifrovaní videa: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    // 4. BEZPEČNOSŤ: Okamžité zmazanie dešifrovaného súboru z disku
    if (_tempFile != null && _tempFile!.existsSync()) {
      _tempFile!.deleteSync();
      debugPrint("🧹 Dešifrovaný dočasný súbor bol odstránený.");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: _isDecrypting
            ? const CircularProgressIndicator(color: Colors.white)
            : (_controller != null && _controller!.value.isInitialized)
            ? AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller!),
              VideoProgressIndicator(_controller!, allowScrubbing: true),
              _PlayPauseOverlay(controller: _controller!),
            ],
          ),
        )
            : const Text("Chyba pri načítaní videa", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.value.isPlaying ? controller.pause() : controller.play(),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: !controller.value.isPlaying
              ? const Icon(Icons.play_arrow, color: Colors.white, size: 80, shadows: [Shadow(blurRadius: 10)])
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:bakalarka/services/sync_service.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bakalarka/generated/l10n.dart';

class VideoGalleryPage extends StatefulWidget {
  const VideoGalleryPage({super.key});

  @override
  State<VideoGalleryPage> createState() => _VideoGalleryPageState();
}

class _VideoGalleryPageState extends State<VideoGalleryPage> {
  final Set<Video> _selectedVideos = {};
  bool _selectionMode = false;
  bool _isSyncing = false;

  // Identity pre Live Sync filtrovanie
  String? _currentUserEmail;
  String? _currentUserRole;
  String? _currentCompanyCode;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  void initState() {
    super.initState();
    _loadUserIdentity();
  }

  Future<void> _loadUserIdentity() async {
    // ZJEDNOTENIE KĽÚČA: Používame company_code pre konzistenciu s AuthService
    final email = await _storage.read(key: 'user_email');
    final role = await _storage.read(key: 'user_role');
    final company = await _storage.read(key: 'company_code');

    if (mounted) {
      debugPrint("📹 Video Gallery Identity: $email, $role, $company");
      setState(() {
        _currentUserEmail = email;
        _currentUserRole = role;
        _currentCompanyCode = company;
      });
    }
  }

  void _toggleSelection(Video video) {
    // Ak je video už na cloude, nenecháme ho znova vyberať pre upload
    if (video.uploaded && !_selectionMode) return;

    setState(() {
      if (_selectedVideos.contains(video)) {
        _selectedVideos.remove(video);
        if (_selectedVideos.isEmpty) _selectionMode = false;
      } else {
        _selectedVideos.add(video);
        _selectionMode = true;
      }
    });
  }

  void _syncSelected(AppDatabase db) async {
    setState(() => _isSyncing = true);
    final syncService = SyncService(db);
    int successCount = 0;

    for (var video in _selectedVideos) {
      final file = File(video.filePath);
      if (await file.exists()) {
        // syncMedia automaticky nahrá súbor a zmení stav v SQLite na 'uploaded = true'
        bool ok = await syncService.syncMedia(file, 'video');
        if (ok) successCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Úspešne nahraných $successCount videí.')),
      );
      setState(() {
        _isSyncing = false;
        _selectedVideos.clear();
        _selectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final theme = Theme.of(context);

    // Kým nemáme identitu, nevieme čo zobraziť (Admin vs Technik)
    if (_currentUserEmail == null || _currentCompanyCode == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_selectionMode)
          Container(
            color: theme.colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${_selectedVideos.length} vybrané', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_isSyncing)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    icon: const Icon(Icons.cloud_upload, color: Colors.blue),
                    onPressed: () => _syncSelected(db),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _selectedVideos.clear();
                    _selectionMode = false;
                  }),
                ),
              ],
            ),
          ),

        Expanded(
          child: StreamBuilder<List<Video>>(
            // LIVE SYNC: Drift automaticky aktualizuje zoznam pri pridaní videa cez SyncService
            stream: _currentUserRole == 'admin'
                ? db.watchCompanyVideos(_currentCompanyCode!)
                : db.watchUserVideos(_currentUserEmail!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final videos = snapshot.data ?? [];
              if (videos.isEmpty) return _buildEmptyState(theme);

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
                  final isSelected = _selectedVideos.contains(video);

                  return GestureDetector(
                    onLongPress: () => _toggleSelection(video),
                    onTap: () {
                      if (_selectionMode) {
                        _toggleSelection(video);
                      } else {
                        _playVideo(context, video);
                      }
                    },
                    child: _VideoCard(
                      video: video,
                      isSelected: isSelected,
                      isSelectionMode: _selectionMode,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          const Text('V trezore zatiaľ nie sú žiadne videá.'),
        ],
      ),
    );
  }

  void _playVideo(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EncryptedVideoPlayer(video: video)),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;
  final bool isSelected;
  final bool isSelectionMode;

  const _VideoCard({
    required this.video,
    required this.isSelected,
    required this.isSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = Provider.of<AppDatabase>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.blue : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: theme.colorScheme.secondaryContainer,
                  child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.black38),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(video.ownerName ?? 'Neznámy',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                          Text("${video.createdAt.day}.${video.createdAt.month}.${video.createdAt.year}",
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (!isSelectionMode)
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                        onPressed: () => _confirmDelete(context, db, video),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
              child: Icon(
                video.uploaded ? Icons.cloud_done : Icons.cloud_off,
                color: video.uploaded ? Colors.greenAccent : Colors.white70,
                size: 16,
              ),
            ),
          ),
          if (isSelected)
            Container(color: Colors.black26, child: const Center(child: Icon(Icons.check_circle, color: Colors.blue, size: 40))),
        ],
      ),
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

// --- DEŠIFROVANÝ PREHRÁVAČ ---

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
      final encryptedFile = File(widget.video.filePath);
      if (!await encryptedFile.exists()) throw Exception("Súbor neexistuje");

      // 1. Dešifrovanie do RAM
      final encryptedBytes = await encryptedFile.readAsBytes();
      final decryptedBytes = await CryptoService.decryptBytes(encryptedBytes);

      // 2. Dočasný zápis na disk (VideoPlayer nevie čítať priamo z bajtov v pamäti)
      final tempDir = await getTemporaryDirectory();
      _tempFile = File('${tempDir.path}/temp_vid_${DateTime.now().millisecondsSinceEpoch}.mp4');
      await _tempFile!.writeAsBytes(decryptedBytes);

      // 3. Inicializácia controllera
      _controller = VideoPlayerController.file(_tempFile!)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isDecrypting = false;
              _controller!.play();
              _controller!.setLooping(true);
            });
          }
        });
    } catch (e) {
      debugPrint("Chyba pri dešifrovaní videa: $e");
      if (mounted) setState(() => _isDecrypting = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    // BEZPEČNOSŤ: Vymažeme dešifrovaný súbor hneď po zatvorení prehrávača
    if (_tempFile != null && _tempFile!.existsSync()) {
      try { _tempFile!.deleteSync(); } catch (e) { debugPrint("Chyba pri mazaní temp: $e"); }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(widget.video.ownerName ?? 'Video', style: const TextStyle(color: Colors.white))
      ),
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
            : const Text("Nepodarilo sa prehrať video", style: TextStyle(color: Colors.white)),
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
        child: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, VideoPlayerValue value, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: !value.isPlaying
                  ? const Icon(Icons.play_arrow, color: Colors.white, size: 80)
                  : const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/security/crypto_service.dart'; // Import tvojho šifrovania
import 'package:audioplayers/audioplayers.dart';

class AudioGalleryPage extends StatefulWidget {
  const AudioGalleryPage({super.key});

  @override
  State<AudioGalleryPage> createState() => _AudioGalleryPageState();
}

class _AudioGalleryPageState extends State<AudioGalleryPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dôležité uvoľniť pamäť
    super.dispose();
  }

  /// Kľúčová funkcia pre bakalárku: Dešifrovanie a prehrávanie z pamäte
  Future<void> _playAudio(Audio audio) async {
    try {
      // Ak už niečo hrá, zastavíme to
      if (_isPlaying && _currentlyPlayingPath == audio.filePath) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
        return;
      }

      // 1. Načítanie zašifrovaných bajtov z disku
      final file = File(audio.filePath);
      final encryptedBytes = await file.readAsBytes();

      // 2. Dešifrovanie bajtov pomocou tvojho CryptoService
      final decryptedBytes = await CryptoService.decryptBytes(encryptedBytes);

      // 3. Prehrávanie priamo z bajtov (BytesSource) - súbor sa neukladá na disk!
      await _audioPlayer.play(BytesSource(Uint8List.fromList(decryptedBytes)));

      setState(() {
        _currentlyPlayingPath = audio.filePath;
        _isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) setState(() => _isPlaying = false);
      });

    } catch (e) {
      debugPrint("Chyba pri prehrávaní: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodarilo sa dešifrovať alebo prehrať zvuk.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final theme = Theme.of(context);

    return StreamBuilder<List<Audio>>(
      stream: db.watchAllAudios(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final audios = snapshot.data ?? [];

        if (audios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_off_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 16),
                const Text('Žiadne nahrávky v trezore'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: audios.length,
          itemBuilder: (context, index) {
            final audio = audios[index];
            final isThisPlaying = _isPlaying && _currentlyPlayingPath == audio.filePath;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: isThisPlaying
                  ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: isThisPlaying ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5)
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isThisPlaying ? theme.colorScheme.primary : theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      isThisPlaying ? Icons.equalizer_rounded : Icons.mic_rounded,
                      color: isThisPlaying ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer
                  ),
                ),
                title: Text(
                  'Nahrávka č. ${audio.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatDate(audio.createdAt)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      icon: Icon(isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      onPressed: () => _playAudio(audio),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      onPressed: () => _confirmDelete(context, db, audio),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} o ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _confirmDelete(BuildContext context, AppDatabase db, Audio audio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vymazať nahrávku?'),
        content: const Text('Tento súbor bude natrvalo odstránený z vášho trezoru.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zrušiť')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vymazať', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_currentlyPlayingPath == audio.filePath) {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
      }
      final file = File(audio.filePath);
      if (await file.exists()) await file.delete();
      await db.deleteAudio(audio.filePath);
    }
  }
}
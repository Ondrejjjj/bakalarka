import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:bakalarka/services/sync_service.dart';
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

  // Logika výberu a synchronizácie
  final Set<Audio> _selectedAudios = {};
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

    // Sledovanie konca prehrávania
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
        });
      }
    });
  }

  // Zosúladenie identity so zvyškom aplikácie
  Future<void> _loadUserIdentity() async {
    final email = await _storage.read(key: 'user_email');
    final role = await _storage.read(key: 'user_role');
    final company = await _storage.read(key: 'company_code'); // OPRAVA KĽÚČA

    if (mounted) {
      debugPrint("🎙️ Audio Gallery Identity: $email, $role, $company");
      setState(() {
        _currentUserEmail = email;
        _currentUserRole = role;
        _currentCompanyCode = company;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleSelection(Audio audio) {
    // Už nahrané súbory nedovoľujeme znova vyberať pre upload
    if (audio.uploaded && !_selectionMode) return;

    setState(() {
      if (_selectedAudios.contains(audio)) {
        _selectedAudios.remove(audio);
        if (_selectedAudios.isEmpty) _selectionMode = false;
      } else {
        _selectedAudios.add(audio);
        _selectionMode = true;
      }
    });
  }

  void _syncSelected(AppDatabase db) async {
    setState(() => _isSyncing = true);
    final syncService = SyncService(db);
    int successCount = 0;

    for (var audio in _selectedAudios) {
      final file = File(audio.filePath);
      if (await file.exists()) {
        // syncMedia nahrá nahrávku a v SQLite ju označí ako 'uploaded'
        bool ok = await syncService.syncMedia(file, 'audio');
        if (ok) successCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Úspešne nahraných $successCount nahrávok.')),
      );
      setState(() {
        _isSyncing = false;
        _selectedAudios.clear();
        _selectionMode = false;
      });
    }
  }

  Future<void> _playAudio(Audio audio) async {
    if (_selectionMode) {
      _toggleSelection(audio);
      return;
    }

    try {
      // Ak už hrá toto isté audio, tak ho zastavíme (Toggle)
      if (_isPlaying && _currentlyPlayingPath == audio.filePath) {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
        return;
      }

      final file = File(audio.filePath);
      if (!await file.exists()) throw Exception("Súbor nahrávky neexistuje");

      // Dešifrovanie priamo do RAM pre maximálnu bezpečnosť
      final encryptedBytes = await file.readAsBytes();
      final decryptedBytes = await CryptoService.decryptBytes(encryptedBytes);

      // Prehráme priamo z bytov (BytesSource)
      await _audioPlayer.play(BytesSource(Uint8List.fromList(decryptedBytes)));

      setState(() {
        _currentlyPlayingPath = audio.filePath;
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint("❌ Chyba pri prehrávaní audia: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodarilo sa dešifrovať alebo prehrať nahrávku.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final theme = Theme.of(context);

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
                Text('${_selectedAudios.length} vybrané', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    _selectedAudios.clear();
                    _selectionMode = false;
                  }),
                ),
              ],
            ),
          ),

        Expanded(
          child: StreamBuilder<List<Audio>>(
            // LIVE SYNC: Admin vidí nahrávky od všetkých, technik len svoje
            stream: _currentUserRole == 'admin'
                ? db.watchCompanyAudios(_currentCompanyCode!)
                : db.watchUserAudios(_currentUserEmail!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final audios = snapshot.data ?? [];
              if (audios.isEmpty) {
                return const Center(child: Text('Trezor nahrávok je prázdny.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: audios.length,
                itemBuilder: (context, index) {
                  final audio = audios[index];
                  final isThisPlaying = _isPlaying && _currentlyPlayingPath == audio.filePath;
                  final isSelected = _selectedAudios.contains(audio);

                  return GestureDetector(
                    onLongPress: () => _toggleSelection(audio),
                    onTap: () => _playAudio(audio),
                    child: Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer.withOpacity(0.7)
                          : (isThisPlaying ? theme.colorScheme.primaryContainer.withOpacity(0.3) : theme.colorScheme.surfaceVariant.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: (isSelected || isThisPlaying) ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Stack(
                          children: [
                            AnimatedContainer(
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
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Icon(
                                audio.uploaded ? Icons.cloud_done : Icons.cloud_off,
                                size: 16,
                                color: audio.uploaded ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                            _currentUserRole == 'admin'
                                ? (audio.ownerName ?? 'Technik: ${audio.ownerName}')
                                : 'Hlasová nahrávka',
                            style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(_formatDate(audio.createdAt)),
                        trailing: _selectionMode
                            ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(audio)
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.filledTonal(
                              icon: Icon(isThisPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
                              onPressed: () => _playAudio(audio),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                              onPressed: () => _confirmDelete(context, db, audio),
                            ),
                          ],
                        ),
                      ),
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

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _confirmDelete(BuildContext context, AppDatabase db, Audio audio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zmazať nahrávku?'),
        content: const Text('Súbor bude natrvalo odstránený.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zrušiť')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Zmazať', style: TextStyle(color: Colors.red))),
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
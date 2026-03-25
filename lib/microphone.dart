import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // PRIDANÉ

// Importy tvojich vlastných služieb
import 'package:bakalarka/database.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:bakalarka/storage/image_storage.dart';
import 'generated/l10n.dart';

class MicrophonePage extends StatefulWidget {
  const MicrophonePage({super.key});

  @override
  State<MicrophonePage> createState() => _MicrophonePageState();
}

class _MicrophonePageState extends State<MicrophonePage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _tempPath = '';
  Duration _recordDuration = Duration.zero;
  Timer? _timer;

  // Secure Storage pre offline prístup k identite
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Lokálna cache pre údaje o používateľovi
  String _cachedEmail = 'unknown_user';
  String _cachedCompany = 'unknown_company';

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadOfflineCredentials(); // Načítame údaje hneď pri štarte
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  // Načítanie údajov zo Secure Storage (funguje aj offline)
  Future<void> _loadOfflineCredentials() async {
    try {
      final email = await _storage.read(key: 'user_email');
      final company = await _storage.read(key: 'company_code');

      if (mounted) {
        setState(() {
          _cachedEmail = email ?? 'offline_user';
          _cachedCompany = company ?? 'offline_company';
        });
      }
    } catch (e) {
      debugPrint("Chyba načítania offline údajov pre audio: $e");
    }
  }

  // --- ZMENA V METÓDE _toggleRecording ---
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _recorder.stopRecorder();
      _timer?.cancel();
      _isRecording = false;

      try {
        final File tempFile = File(_tempPath);
        if (!await tempFile.exists()) return;

        final bytes = await tempFile.readAsBytes();

        // 1. Šifrovanie bajtov
        final encryptedBytes = await CryptoService.encryptBytes(bytes);

        // 2. Vytvorenie bezpečného názvu
        final audioId = 'REC_${DateTime.now().millisecondsSinceEpoch}';
        final secureFile = await ImageStorage.createEncryptedFile(audioId);

        // 3. Zápis šifrovaných dát
        await secureFile.writeAsBytes(encryptedBytes, flush: true);

        // 4. Zápis do SQLCipher databázy (DYNAMICKÉ ÚDAJE)
        final db = context.read<AppDatabase>();

        // OPRAVENÁ ČASŤ:
        await db.insertAudio(
          filePath: secureFile.path,
          // deviceId už nie je 90, ale ID nahrávky alebo ID stroja, ak ho máš
          deviceId: audioId,
          // ownerName načítame z e-mailu (odstránime časť za zavináčom pre krajšie meno)
          ownerName: _cachedEmail.split('@')[0],
          userEmail: _cachedEmail,
          companyCode: _cachedCompany,
          duration: _recordDuration.inSeconds,
          uploaded: false,
        );

        // 5. Vymazanie nezašifrovaného súboru
        await tempFile.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).spravaAudioV),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Chyba pri zabezpečení audia: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chyba pri ukladaní nahrávky')),
          );
        }
      }
    } else {
      // --- ŠTART NAHRÁVANIA (Ostáva rovnaký) ---
      final dir = await getTemporaryDirectory();
      _tempPath = '${dir.path}/temp_rec_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: _tempPath,
        codec: Codec.aacADTS,
      );

      _isRecording = true;
      _recordDuration = Duration.zero;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordDuration += const Duration(seconds: 1);
          });
        }
      });
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(S.of(context).recordAudio),
        surfaceTintColor: theme.colorScheme.surfaceTint,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Časovač
            if (_isRecording)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _formatDuration(_recordDuration),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 40),

            /// TLAČIDLO Nahrávania
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  boxShadow: _isRecording
                      ? [
                    BoxShadow(
                      color: theme.colorScheme.error.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    )
                  ]
                      : [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: theme.colorScheme.onPrimary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// Popis
            Text(
              _isRecording ? 'Nahrávam...' : 'Stlač pre nahrávanie',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
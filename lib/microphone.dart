import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Otvorenie rekordéra a inicializácia audio session
    await _recorder.openRecorder();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // --- ZASTAVENIE NAHRÁVANIA ---
      await _recorder.stopRecorder();
      _timer?.cancel();
      _isRecording = false;

      try {
        // 1. Načítanie dočasného súboru
        final File tempFile = File(_tempPath);
        if (!await tempFile.exists()) return;

        final bytes = await tempFile.readAsBytes();

        // 2. Šifrovanie bajtov (AES-256)
        final encryptedBytes = await CryptoService.encryptBytes(bytes);

        // 3. Vytvorenie bezpečného názvu a súboru v aplikácii
        final audioId = 'REC_${DateTime.now().millisecondsSinceEpoch}';
        final secureFile = await ImageStorage.createEncryptedFile(audioId);

        // 4. Zápis šifrovaných dát
        await secureFile.writeAsBytes(encryptedBytes, flush: true);

        // 5. Zápis do SQLCipher databázy
        final db = context.read<AppDatabase>();
        await db.insertAudio(
          filePath: secureFile.path,
          deviceId: '90',
          ownerName: "user",
          duration: _recordDuration.inSeconds,
        );

        // 6. Vymazanie nezašifrovaného súboru z cache
        await tempFile.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔐 Nahrávka zašifrovaná a uložená do databázy'),
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
      // --- ŠTART NAHRÁVANIA ---
      final dir = await getTemporaryDirectory();
      _tempPath = '${dir.path}/temp_rec_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: _tempPath,
        codec: Codec.aacADTS,
      );

      _isRecording = true;
      _recordDuration = Duration.zero;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration += const Duration(seconds: 1);
        });
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
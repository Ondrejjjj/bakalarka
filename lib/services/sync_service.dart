import 'dart:io';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/services/cloud_service.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:path_provider/path_provider.dart';

class SyncService {
  final AppDatabase db;
  final CloudService cloud = CloudService();

  SyncService(this.db);

  /// Synchronizuje zašifrovaný súbor do Firebase Cloudu.
  /// Vracia [true] ak bola operácia úspešná.
  Future<bool> syncMedia(File encryptedFile, String type) async {
    File? tempFile;
    try {
      // 1. Kontrola, či súbor existuje
      if (!await encryptedFile.exists()) {
        print("❌ Súbor neexistuje: ${encryptedFile.path}");
        return false;
      }

      // 2. Dešifrovanie do pamäte (RAM)
      final bytes = await encryptedFile.readAsBytes();
      final decryptedBytes = await CryptoService.decryptBytes(bytes);

      // 3. Vytvorenie unikátneho dočasného súboru v cache priečinku
      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/temp_sync_${DateTime.now().millisecondsSinceEpoch}');
      await tempFile.writeAsBytes(decryptedBytes);

      // 4. Odoslanie na Firebase Cloud
      // Poznámka: CloudService.uploadMedia musí tiež vracať Future<bool>
      bool success = await cloud.uploadMedia(tempFile, type);

      if (success) {
        // 5. Ak upload prešiel, označíme v SQLCipher ako nahrané
        if (type == 'image') {
          await db.markPhotoAsUploaded(encryptedFile.path);
        } else if (type == 'video') {
          await db.markVideoAsUploaded(encryptedFile.path);
        } else if (type == 'audio') {
          await db.markAudioAsUploaded(encryptedFile.path);
        }
        print("✅ Synchronizácia úspešná pre: ${encryptedFile.path}");
        return true;
      } else {
        print("❌ CloudService vrátil chybu pri uploade.");
        return false;
      }
    } catch (e) {
      print("❌ Kritická chyba v SyncService: $e");
      return false;
    } finally {
      // 6. Zmazanie dočasného súboru kvôli bezpečnosti (vždy, aj pri chybe)
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
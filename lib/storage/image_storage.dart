import 'dart:io';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:bakalarka/database.dart';
import 'dart:typed_data';

class ImageStorage {
  final AppDatabase db;
  ImageStorage(this.db);

  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final secureDir = Directory(p.join(dir.path, 'secure_images'));
    if (!await secureDir.exists()) {
      await secureDir.create(recursive: true);
    }
    return secureDir;
  }

  static Future<List<File>> getAllEncryptedFiles() async {
    final dir = await _baseDir();
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.enc'))
        .toList();
  }

  static Future<File> createEncryptedFile(String id) async {
    final dir = await _baseDir();
    return File(p.join(dir.path, '$id.enc'));
  }

  // --- UPRAVENÁ METÓDA NA UKLADANIE ---
  Future<void> saveSecurePhoto({
    required Uint8List originalBytes,
    required String photoId,
    required String userEmail,    // PRIDANÉ
    required String companyCode,  // PRIDANÉ
    String? ownerName,            // Odporúčam pridať pre zobrazenie mena adminovi
    double? latitude,
    double? longitude,
  }) async {
    // 1. Zašifrujeme dáta
    final encryptedBytes = await CryptoService.encryptBytes(originalBytes);

    // 2. Vytvoríme súbor v secure priečinku
    final file = await ImageStorage.createEncryptedFile(photoId);

    // 3. Zapíšeme zašifrované dáta na disk
    await file.writeAsBytes(encryptedBytes);

    // 4. Uložíme záznam do Drift databázy so všetkými novými stĺpcami
    await db.insertPhoto(
      filePath: file.path,
      deviceId: "mobile_1", // Tu môžeš neskôr doplniť reálne ID zariadenia
      userEmail: userEmail,
      companyCode: companyCode,
      ownerName: ownerName,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
import 'dart:io';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:bakalarka/database.dart';
import 'dart:typed_data';

class ImageStorage {
  // Databázu by si mal dostávať zvonku (napr. cez konštruktor alebo Provider)
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

  // Vytvorenie súboru (používame len ID, nie celú cestu)
  static Future<File> createEncryptedFile(String id) async {
    final dir = await _baseDir();
    return File(p.join(dir.path, '$id.enc'));
  }

  // Získanie obľúbených - bezpečný prístup
  Future<List<File>> getFavoriteEncryptedFiles() async {
    final favoritePhotos = await db.getFavoritePhotos();
    final List<File> files = [];

    for (var photo in favoritePhotos) {
      final file = File(photo.filePath);
      if (await file.exists()) {
        files.add(file);
      }
    }
    return files;
  }
  // V ImageStorage alebo v nejakej Logike:
  Future<void> saveSecurePhoto(Uint8List originalBytes, String photoId) async {
    // 1. Zašifrujeme dáta
    final encryptedBytes = await CryptoService.encryptBytes(originalBytes);

    // 2. Vytvoríme súbor v secure priečinku
    final file = await ImageStorage.createEncryptedFile(photoId);

    // 3. Zapíšeme zašifrované dáta na disk
    await file.writeAsBytes(encryptedBytes);

    // 4. Uložíme záznam do Drift databázy
    await db.insertPhoto(
      filePath: file.path,
      deviceId: "mobile_1",
      // ... ďalšie údaje
    );
  }
}
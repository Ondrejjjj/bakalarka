import 'dart:io';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:bakalarka/database.dart';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';

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

  Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unikátne ID pre Android (napr. SSAID)
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios'; // ID pre iOS
    }
    return 'unknown_device';
  }

  Future<void> saveSecurePhoto({
    required Uint8List originalBytes,
    required String photoId,
    required String userEmail,
    required String companyCode,
    String? ownerName,
    double? latitude,
    double? longitude,
  }) async {
    // 1. Zašifrujeme dáta
    final encryptedBytes = await CryptoService.encryptBytes(originalBytes);

    // 2. Vytvoríme súbor v secure priečinku
    final file = await ImageStorage.createEncryptedFile(photoId);

    // 3. Zapíšeme zašifrované dáta na disk
    await file.writeAsBytes(encryptedBytes);

    String realId = await getDeviceId();

    // 4. Uložíme záznam do Drift databázy
    await db.insertPhoto(
      filePath: file.path,
      deviceId: realId,
      userEmail: userEmail,
      companyCode: companyCode,
      ownerName: ownerName,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageStorage {
  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final secureDir = Directory(p.join(dir.path, 'secure_images'));

    if (!await secureDir.exists()) {
      await secureDir.create(recursive: true);
    }

    return secureDir;
  }

  static Future<File> createEncryptedFile(String id) async {
    final dir = await _baseDir();
    return File(p.join(dir.path, '$id.enc'));
  }

  static Future<List<File>> getAllEncryptedFiles() async {
    final dir = await _baseDir();
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.enc'))
        .toList();
  }
}

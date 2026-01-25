import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:bakalarka/database.dart';

class ImageStorage {
  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final secureDir = Directory(p.join(dir.path, 'secure_images'));

    if (!await secureDir.exists()) {
      await secureDir.create(recursive: true);
    }

    return secureDir;
  }
  final AppDatabase db = AppDatabase();
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

   Future<List<File>> getFavoriteEncryptedFiles() async {
    final favoritePhotos = await db.getFavoritePhotos();

    return favoritePhotos
        .map((p) => File(p.filePath))
        .where((f) => f.existsSync())
        .toList();
  }

}

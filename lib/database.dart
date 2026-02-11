import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

part 'database.g.dart';

/// --------------- Secure Storage ----------------
final secureStorage = const FlutterSecureStorage();

Future<String> getDbPassword() async {
  var pwd = await secureStorage.read(key: 'db_password');
  if (pwd == null) {
    pwd = 'db_${DateTime.now().millisecondsSinceEpoch}';
    await secureStorage.write(key: 'db_password', value: pwd);
  }
  return pwd;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));

    final password = await getDbPassword();

    return NativeDatabase(
      file,
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = '$password';");
      },
    );
  });
}

// --------------- TABUĽKY ----------------

// Upravená tabuľka Users pre synchronizáciu s Firebase
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().unique()(); // Firebase UID
  TextColumn get email => text()();
  TextColumn get role => text()(); // admin / technician
  TextColumn get companyCode => text()(); // companyId z Firebase
}

class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get userEmail => text()();
  TextColumn get companyCode => text()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
}

class Audios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get userEmail => text()();
  TextColumn get companyCode => text()();
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
}

class Videos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get userEmail => text()();
  TextColumn get companyCode => text()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
  IntColumn get durationSeconds => integer().nullable()();
}

// --------------- Drift Database ----------------

@DriftDatabase(tables: [Users, Photos, Audios, Videos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7; // Zvýšené na 7 kvôli zmene tabuľky Users

  // ---------------- USER CRUD (Nové) ----------------

  Future<int> upsertUser(UsersCompanion user) {
    return into(users).insertOnConflictUpdate(user);
  }

  Future<User?> getUser(String uid) {
    return (select(users)..where((u) => u.uid.equals(uid))).getSingleOrNull();
  }

  // ---------------- FILTROVANÉ STREAMY PRE POUŽÍVATEĽA (Technik) ----------------

  Stream<List<Photo>> watchUserPhotos(String email) {
    return (select(photos)..where((p) => p.userEmail.equals(email))).watch();
  }

  Stream<List<Video>> watchUserVideos(String email) {
    return (select(videos)..where((v) => v.userEmail.equals(email))).watch();
  }

  Stream<List<Audio>> watchUserAudios(String email) {
    return (select(audios)..where((a) => a.userEmail.equals(email))).watch();
  }

  // ---------------- FILTROVANÉ STREAMY PRE FIRMU (Admin) ----------------

  Stream<List<Photo>> watchCompanyPhotos(String companyCode) {
    return (select(photos)..where((p) => p.companyCode.equals(companyCode))).watch();
  }

  Stream<List<Video>> watchCompanyVideos(String companyCode) {
    return (select(videos)..where((v) => v.companyCode.equals(companyCode))).watch();
  }

  Stream<List<Audio>> watchCompanyAudios(String companyCode) {
    return (select(audios)..where((a) => a.companyCode.equals(companyCode))).watch();
  }

  // ---------------- SYNC LOGIKA ----------------

  Future<void> markPhotoAsUploaded(String filePath) {
    return (update(photos)..where((p) => p.filePath.equals(filePath))).write(
      const PhotosCompanion(uploaded: Value(true)),
    );
  }

  Future<void> markVideoAsUploaded(String filePath) {
    return (update(videos)..where((v) => v.filePath.equals(filePath))).write(
      const VideosCompanion(uploaded: Value(true)),
    );
  }

  Future<void> markAudioAsUploaded(String filePath) {
    return (update(audios)..where((a) => a.filePath.equals(filePath))).write(
      const AudiosCompanion(uploaded: Value(true)),
    );
  }

  // ---------------- PHOTOS CRUD ----------------
  Future<int> insertPhoto({
    required String filePath,
    required String deviceId,
    required String userEmail,
    required String companyCode,
    String? ownerName,
    bool uploaded = false,
    double? latitude,
    double? longitude,
  }) async {
    return await into(photos).insert(
      PhotosCompanion(
        filePath: Value(filePath),
        deviceId: Value(deviceId),
        userEmail: Value(userEmail),
        companyCode: Value(companyCode),
        ownerName: Value(ownerName),
        uploaded: Value(uploaded),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ),
    );
  }

  Future<void> deletePhoto(String filePath) async {
    await (delete(photos)..where((p) => p.filePath.equals(filePath))).go();
  }

  Future<void> toggleFavorite(String filePath, bool value) {
    return (update(photos)..where((p) => p.filePath.equals(filePath))).write(
      PhotosCompanion(favorite: Value(value)),
    );
  }

  // ---------------- AUDIOS CRUD ----------------
  Future<int> insertAudio({
    required String filePath,
    required String deviceId,
    required String userEmail,
    required String companyCode,
    String? ownerName,
    int? duration,
    bool uploaded = false,
  }) {
    return into(audios).insert(
      AudiosCompanion(
        filePath: Value(filePath),
        deviceId: Value(deviceId),
        userEmail: Value(userEmail),
        companyCode: Value(companyCode),
        ownerName: Value(ownerName),
        durationSeconds: Value(duration),
        uploaded: Value(uploaded),
      ),
    );
  }

  Future<void> deleteAudio(String filePath) async {
    await (delete(audios)..where((a) => a.filePath.equals(filePath))).go();
  }

  // ---------------- VIDEOS CRUD ----------------
  Future<int> insertVideo({
    required String filePath,
    required String deviceId,
    required String userEmail,
    required String companyCode,
    String? ownerName,
    bool uploaded = false,
    int? duration,
  }) {
    return into(videos).insert(
      VideosCompanion(
        filePath: Value(filePath),
        deviceId: Value(deviceId),
        userEmail: Value(userEmail),
        companyCode: Value(companyCode),
        ownerName: Value(ownerName),
        uploaded: Value(uploaded),
        durationSeconds: Value(duration),
      ),
    );
  }

  Future<void> deleteVideo(String filePath) async {
    await (delete(videos)..where((v) => v.filePath.equals(filePath))).go();
  }

  // ---------------- MIGRATION STRATEGY ----------------
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(photos, photos.latitude);
        await m.addColumn(photos, photos.longitude);
      }
      if (from < 3) await m.createTable(audios);
      if (from < 4) await m.createTable(videos);
      if (from < 5) await m.addColumn(audios, audios.uploaded);
      if (from < 6) {
        await m.addColumn(photos, photos.userEmail);
        await m.addColumn(photos, photos.companyCode);
        await m.addColumn(audios, audios.userEmail);
        await m.addColumn(audios, audios.companyCode);
        await m.addColumn(videos, videos.userEmail);
        await m.addColumn(videos, videos.companyCode);
      }
      if (from < 7) {
        // Pri zmene štruktúry Users je najbezpečnejšie tabuľku dropnúť a vytvoriť znova
        await m.deleteTable('users');
        await m.createTable(users);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
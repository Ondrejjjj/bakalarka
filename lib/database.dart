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
final secureStorage = FlutterSecureStorage();

Future<String> getDbPassword() async {
  var pwd = await secureStorage.read(key: 'db_password');
  if (pwd == null) {
    pwd = 'db_' + DateTime.now().millisecondsSinceEpoch.toString();
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

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get password => text()();
  TextColumn get email => text()();
}

class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text()();
  TextColumn get ownerName => text().nullable()();
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
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  // Pridaný stĺpec pre synchronizáciu
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
}

class Videos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text()();
  TextColumn get ownerName => text().nullable()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
  IntColumn get durationSeconds => integer().nullable()();
}

// --------------- Drift Database ----------------

@DriftDatabase(tables: [Users, Photos, Audios, Videos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // Zvýšené na 5

  // ---------------- USERS CRUD ----------------
  Future<int> createUser(String username, String password, String email) {
    return into(users).insert(
      UsersCompanion(
        username: Value(username),
        password: Value(password),
        email: Value(email),
      ),
    );
  }

  Future<List<User>> getAllUsers() => select(users).get();

  Future<User?> getUserByUsername(String username) {
    return (select(users)..where((u) => u.username.equals(username)))
        .getSingleOrNull();
  }

  // ---------------- SYNC LOGIKA (Nové funkcie) ----------------

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
    String? ownerName,
    bool uploaded = false,
    double? latitude,
    double? longitude,
  }) async {
    return await into(photos).insert(
      PhotosCompanion(
        filePath: Value(filePath),
        deviceId: Value(deviceId),
        ownerName: Value(ownerName),
        uploaded: Value(uploaded),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ),
    );
  }

  Future<List<Photo>> getAllPhotos() => select(photos).get();
  Stream<List<Photo>> watchAllPhotos() => select(photos).watch();

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
    String? ownerName,
    int? duration,
    bool uploaded = false,
  }) {
    return into(audios).insert(
      AudiosCompanion(
        filePath: Value(filePath),
        deviceId: Value(deviceId),
        ownerName: Value(ownerName),
        durationSeconds: Value(duration),
        uploaded: Value(uploaded),
      ),
    );
  }

  Future<List<Audio>> getAllAudios() => select(audios).get();
  Stream<List<Audio>> watchAllAudios() => select(audios).watch();

  Future<void> deleteAudio(String filePath) async {
    await (delete(audios)..where((a) => a.filePath.equals(filePath))).go();
  }

  Future<void> toggleAudioFavorite(String filePath, bool value) {
    return (update(audios)..where((a) => a.filePath.equals(filePath))).write(
      AudiosCompanion(favorite: Value(value)),
    );
  }

  // ---------------- VIDEOS CRUD ----------------
  Future<int> insertVideo({
    required String filePath,
    required String deviceId,
    String? ownerName,
    bool uploaded = false,
    int? duration,
  }) {
    return into(videos).insert(
      VideosCompanion(
        filePath: Value(filePath),
        deviceId: Value(deviceId),
        ownerName: Value(ownerName),
        uploaded: Value(uploaded),
        durationSeconds: Value(duration),
      ),
    );
  }

  Stream<List<Video>> watchAllVideos() => select(videos).watch();

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
      if (from < 5) {
        // Pridá stĺpec uploaded do už existujúcej tabuľky audios
        await m.addColumn(audios, audios.uploaded);
      }
    },
  );
}
import 'dart:io';
import 'dart:convert'; // Pridané pre spracovanie JSON (techSpecs, history)
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

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().unique()(); // Firebase UID
  TextColumn get email => text()();
  TextColumn get role => text()(); // admin / technician
  TextColumn get companyCode => text()(); // companyId z Firebase
}

// *** NOVÁ TABUĽKA PRE EVIDENCIU MAJETKU ***
class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable().unique()(); // UID z Firebase pre synchro
  TextColumn get name => text()();
  TextColumn get sn => text()(); // Sériové číslo (unikátne číslo pre vyhľadávanie)
  TextColumn get model => text()();
  TextColumn get url => text().nullable()();
  TextColumn get status => text()(); // V prevádzke, Vyžaduje servis, atď.

  // Dynamické polia ukladané ako JSON String
  TextColumn get techSpecs => text()();
  TextColumn get history => text()();

  TextColumn get userEmail => text()(); // Kto zariadenie pridal/upravil
  TextColumn get companyCode => text()(); // Príslušnosť k firme

  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))(); // Stav synchronizácie
  DateTimeColumn get lastModified => dateTime().withDefault(currentDateAndTime)();
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

@DriftDatabase(tables: [Users, Assets, Photos, Audios, Videos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8; // Zvýšené na 8 kvôli pridaniu tabuľky Assets

  // ---------------- ASSETS CRUD (Majetok) - NOVÉ ----------------

  // Sledovanie majetku pre celú firmu (aby kolegovia videli zmeny po synchre)
  Stream<List<Asset>> watchCompanyAssets(String companyCode) {
    return (select(assets)
      ..where((a) => a.companyCode.equals(companyCode))
      ..orderBy([(a) => OrderingTerm(expression: a.lastModified, mode: OrderingMode.desc)]))
        .watch();
  }

  // Vyhľadávanie majetku podľa SN alebo názvu v rámci firmy
  Future<List<Asset>> searchAssets(String query, String companyCode) {
    return (select(assets)
      ..where((a) => a.companyCode.equals(companyCode) &
      (a.sn.like('%$query%') | a.name.like('%$query%'))))
        .get();
  }

  // Pridanie alebo aktualizácia majetku (používa sa pri lokálnom zápise aj pri sťahovaní z Firebase)
  Future<int> upsertAsset(AssetsCompanion asset) {
    return into(assets).insertOnConflictUpdate(asset);
  }

  // Zmazanie majetku (v UI je potrebné skontrolovať rolu admina)
  Future<void> deleteAsset(int id) {
    return (delete(assets)..where((a) => a.id.equals(id))).go();
  }

  // Označenie majetku ako synchronizovaného po úspešnom odoslaní na Firebase
  Future<void> markAssetAsSynced(int localId, String firebaseId) {
    return (update(assets)..where((a) => a.id.equals(localId))).write(
      AssetsCompanion(
        firebaseId: Value(firebaseId),
        isUploaded: Value(true),
      ),
    );
  }

  // ---------------- USER CRUD ----------------

  Future<int> upsertUser(UsersCompanion user) {
    return into(users).insertOnConflictUpdate(user);
  }

  Future<User?> getUser(String uid) {
    return (select(users)..where((u) => u.uid.equals(uid))).getSingleOrNull();
  }

  // ---------------- FILTROVANÉ STREAMY (Pôvodné) ----------------

  Stream<List<Photo>> watchUserPhotos(String email) {
    return (select(photos)..where((p) => p.userEmail.equals(email))).watch();
  }

  Stream<List<Video>> watchUserVideos(String email) {
    return (select(videos)..where((v) => v.userEmail.equals(email))).watch();
  }

  Stream<List<Audio>> watchUserAudios(String email) {
    return (select(audios)..where((a) => a.userEmail.equals(email))).watch();
  }

  Stream<List<Photo>> watchCompanyPhotos(String companyCode) {
    return (select(photos)..where((p) => p.companyCode.equals(companyCode))).watch();
  }

  Stream<List<Video>> watchCompanyVideos(String companyCode) {
    return (select(videos)..where((v) => v.companyCode.equals(companyCode))).watch();
  }

  Stream<List<Audio>> watchCompanyAudios(String companyCode) {
    return (select(audios)..where((a) => a.companyCode.equals(companyCode))).watch();
  }

  // ---------------- SYNC LOGIKA (Pôvodné) ----------------

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

  // ---------------- PHOTOS CRUD (Pôvodné) ----------------
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

  // ---------------- AUDIOS CRUD (Pôvodné) ----------------
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

  // ---------------- VIDEOS CRUD (Pôvodné) ----------------
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
        await m.deleteTable('users');
        await m.createTable(users);
      }
      if (from < 8) {
        // Vytvorenie novej tabuľky pre majetok
        await m.createTable(assets);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
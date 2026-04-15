import 'dart:io';
import 'dart:convert'; // Pre spracovanie JSON (techSpecs, history, extraData)
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
// PRIDANÉ: Potrebné pre metódu syncMovementToFirebase
import 'package:cloud_firestore/cloud_firestore.dart';

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

// Tabuľka pre EVIDENCIU MAJETKU
class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get sn => text()();
  TextColumn get model => text()();
  TextColumn get url => text().nullable()();
  TextColumn get status => text()();
  TextColumn get techSpecs => text()(); // JSON
  TextColumn get history => text()(); // JSON
  TextColumn get userEmail => text()();
  TextColumn get companyCode => text()();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastModified => dateTime().withDefault(currentDateAndTime)();
}


class Inventory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()(); // ID z Firestore
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get sku => text().withLength(min: 1, max: 50)(); // Skladové označenie
  TextColumn get ean => text().withLength(min: 1, max: 50)(); // Čiarový kód / Unikátne ID
  RealColumn get qty => real().withDefault(const Constant(0.0))(); // Množstvo
  TextColumn get unit => text().withLength(min: 1, max: 10)(); // ks, m, kg...

  // Priradenie k firme a používateľovi
  TextColumn get userEmail => text()();
  TextColumn get companyCode => text()();

  DateTimeColumn get lastModified => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
}

// *** NOVÁ TABUĽKA PRE HISTÓRIU POHYBOV (STOCK MOVEMENTS) ***
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  IntColumn get inventoryId => integer().references(Inventory, #id)(); // Väzba na položku
  TextColumn get itemName => text()();
  RealColumn get changeQty => real()();
  TextColumn get type => text()(); // "income" alebo "outcome"

  // Dynamické dáta uložené ako JSON (Zákazka, poznámka, dodávateľ...)
  TextColumn get extraData => text().withLength(max: 1000).withDefault(const Constant('{}'))();

  TextColumn get userEmail => text()();
  TextColumn get companyCode => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
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

@DriftDatabase(tables: [Users, Assets, Inventory, StockMovements, Photos, Audios, Videos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9; // Zvýšené na 9 (Pridaný sklad a pohyby)



  // Sledovanie zásob pre konkrétnu firmu
  Stream<List<InventoryData>> watchCompanyInventory(String companyCode) {
    return (select(inventory)..where((t) => t.companyCode.equals(companyCode))).watch();
  }

  // Pridanie alebo aktualizácia položky (pri synchre z Firebase)
  Future<int> upsertInventoryItem(InventoryCompanion item) async {
    return into(inventory).insertOnConflictUpdate(item);
  }

  // --- POHYBY (MOVEMENTS) ---

  // Vykonanie skladového pohybu (Atomická operácia)
  Future<void> registerMovement(InventoryData item, StockMovementsCompanion movement) async {
    await transaction(() async {
      // 1. Zapíšeme pohyb do histórie
      await into(stockMovements).insert(movement);

      // 2. Aktualizujeme stav na hlavnom sklade
      final newQty = item.qty + movement.changeQty.value;
      await (update(inventory)..where((t) => t.id.equals(item.id))).write(
        InventoryCompanion(
          qty: Value(newQty),
          lastModified: Value(DateTime.now()),
          isUploaded: const Value(false), // Musí sa znova synchnúť
        ),
      );
    });
  }

  // Sledovanie histórie pohybov
  Stream<List<StockMovement>> watchMovementHistory(String companyCode) {
    return (select(stockMovements)
      ..where((t) => t.companyCode.equals(companyCode))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // ---------------- FIREBASE SYNC - NOVÉ ----------------
  Future<void> syncMovementToFirebase(StockMovement move, InventoryData item) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // 1. Pošleme pohyb do kolekcie 'movements'
      final moveRef = await firestore.collection('movements').add({
        'itemName': move.itemName,
        'changeQty': move.changeQty,
        'type': move.type,
        'extraData': jsonDecode(move.extraData),
        'companyCode': move.companyCode,
        'userEmail': move.userEmail,
        'createdAt': move.createdAt.toIso8601String(),
      });

      // 2. Aktualizujeme stav položky na Firebase (aby ostatní videli nový stav zásob)
      // Hľadáme podľa EAN/SKU v rámci firmy
      final itemQuery = await firestore.collection('inventory')
          .where('companyCode', isEqualTo: item.companyCode)
          .where('ean', isEqualTo: item.ean)
          .limit(1)
          .get();

      if (itemQuery.docs.isNotEmpty) {
        await itemQuery.docs.first.reference.update({
          'qty': item.qty, // Nové vypočítané množstvo
          'lastModified': DateTime.now().toIso8601String(),
        });
      } else {
        // Ak položka na Firebase ešte nie je, vytvoríme ju
        await firestore.collection('inventory').add({
          'name': item.name,
          'ean': item.ean,
          'sku': item.sku,
          'qty': item.qty,
          'unit': item.unit,
          'companyCode': item.companyCode,
          'lastModified': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("Chyba synchronizácie skladu: $e");
    }
  }

  // ---------------- ASSETS CRUD (Majetok) ----------------

  Stream<List<Asset>> watchCompanyAssets(String companyCode) {
    return (select(assets)
      ..where((a) => a.companyCode.equals(companyCode))
      ..orderBy([(a) => OrderingTerm(expression: a.lastModified, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<Asset>> searchAssets(String query, String companyCode) {
    return (select(assets)
      ..where((a) => a.companyCode.equals(companyCode) &
      (a.sn.like('%$query%') | a.name.like('%$query%'))))
        .get();
  }

  Future<int> upsertAsset(AssetsCompanion asset) {
    return into(assets).insertOnConflictUpdate(asset);
  }

  Future<void> deleteAsset(int id) {
    return (delete(assets)..where((a) => a.id.equals(id))).go();
  }

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

  // ---------------- Pôvodné metódy (Photos, Videos, Audios) ----------------

  Stream<List<Photo>> watchUserPhotos(String email) => (select(photos)..where((p) => p.userEmail.equals(email))).watch();
  Stream<List<Video>> watchUserVideos(String email) => (select(videos)..where((v) => v.userEmail.equals(email))).watch();
  Stream<List<Audio>> watchUserAudios(String email) => (select(audios)..where((a) => a.userEmail.equals(email))).watch();

  Stream<List<Photo>> watchCompanyPhotos(String companyCode) => (select(photos)..where((p) => p.companyCode.equals(companyCode))).watch();
  Stream<List<Video>> watchCompanyVideos(String companyCode) => (select(videos)..where((v) => v.companyCode.equals(companyCode))).watch();
  Stream<List<Audio>> watchCompanyAudios(String companyCode) => (select(audios)..where((a) => a.companyCode.equals(companyCode))).watch();

  Future<void> markPhotoAsUploaded(String filePath) => (update(photos)..where((p) => p.filePath.equals(filePath))).write(const PhotosCompanion(uploaded: Value(true)));
  Future<void> markVideoAsUploaded(String filePath) => (update(videos)..where((v) => v.filePath.equals(filePath))).write(const VideosCompanion(uploaded: Value(true)));
  Future<void> markAudioAsUploaded(String filePath) => (update(audios)..where((a) => a.filePath.equals(filePath))).write(const AudiosCompanion(uploaded: Value(true)));

  Future<int> insertPhoto({required String filePath, required String deviceId, required String userEmail, required String companyCode, String? ownerName, bool uploaded = false, double? latitude, double? longitude}) {
    return into(photos).insert(PhotosCompanion(filePath: Value(filePath), deviceId: Value(deviceId), userEmail: Value(userEmail), companyCode: Value(companyCode), ownerName: Value(ownerName), uploaded: Value(uploaded), latitude: Value(latitude), longitude: Value(longitude)));
  }
  Future<void> deletePhoto(String filePath) => (delete(photos)..where((p) => p.filePath.equals(filePath))).go();
  Future<void> toggleFavorite(String filePath, bool value) => (update(photos)..where((p) => p.filePath.equals(filePath))).write(PhotosCompanion(favorite: Value(value)));

  Future<int> insertAudio({required String filePath, required String deviceId, required String userEmail, required String companyCode, String? ownerName, int? duration, bool uploaded = false}) {
    return into(audios).insert(AudiosCompanion(filePath: Value(filePath), deviceId: Value(deviceId), userEmail: Value(userEmail), companyCode: Value(companyCode), ownerName: Value(ownerName), durationSeconds: Value(duration), uploaded: Value(uploaded)));
  }
  Future<void> deleteAudio(String filePath) => (delete(audios)..where((a) => a.filePath.equals(filePath))).go();

  Future<int> insertVideo({required String filePath, required String deviceId, required String userEmail, required String companyCode, String? ownerName, bool uploaded = false, int? duration}) {
    return into(videos).insert(VideosCompanion(filePath: Value(filePath), deviceId: Value(deviceId), userEmail: Value(userEmail), companyCode: Value(companyCode), ownerName: Value(ownerName), uploaded: Value(uploaded), durationSeconds: Value(duration)));
  }
  Future<void> deleteVideo(String filePath) => (delete(videos)..where((v) => v.filePath.equals(filePath))).go();

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
        await m.createTable(assets);
      }
      if (from < 9) {
        // Migrácia na verziu 9: Pridanie tabuliek pre sklad
        await m.createTable(inventory);
        await m.createTable(stockMovements);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
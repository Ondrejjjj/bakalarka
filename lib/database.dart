import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

part 'database.g.dart';

// --------------- Secure Storage ----------------
final secureStorage = FlutterSecureStorage();

/// Funkcia, ktorá vráti heslo pre databázu
/// Ak ešte neexistuje, vygeneruje náhodné a uloží
Future<String> getDbPassword() async {
  var pwd = await secureStorage.read(key: 'db_password');
  if (pwd == null) {
    // Jednoduchá generácia hesla
    pwd = 'db_' + DateTime.now().millisecondsSinceEpoch.toString();
    await secureStorage.write(key: 'db_password', value: pwd);
  }
  return pwd;
}

// --------------- Otváranie šifrovanej databázy ----------------
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));

    // Načítame heslo zo secure storage
    final password = await getDbPassword();

    // Šifrovaná databáza cez SQLCipher
    final executor = NativeDatabase(file, setup: (db) {
      db.execute("PRAGMA key = '$password';");
    });

    return executor;
  });
}

// --------------- Prvá tabuľka: Users ----------------
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get password => text()(); // tu by si mohol ukladať hash hesla
  TextColumn get email => text()();
}

// --------------- Drift Database ----------------
@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --------------- Príklad CRUD ----------------
  Future<int> createUser(String username, String password, String email) {
    return into(users).insert(
      UsersCompanion(
        username: Value(username),
        password: Value(password),
        email: Value(email),
      ),
    );
  }

  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  Future<User?> getUserByUsername(String username) {
    return (select(users)..where((u) => u.username.equals(username))).getSingleOrNull();
  }
}

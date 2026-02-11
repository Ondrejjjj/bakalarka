import 'package:firebase_auth/firebase_auth.dart' as fb; // Alias pre Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'package:drift/drift.dart';
import '../database.dart'; // Uisti sa, že cesta k database.dart je správna

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Odkaz na Drift databázu
  final AppDatabase _localDb = AppDatabase();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // --- SYNCHRONIZÁCIA: SECURE STORAGE + DRIFT DATABASE ---
  Future<void> syncUserToSecureStorage(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final String email = data['email'] ?? '';
        final String role = data['role'] ?? '';
        final String companyId = data['companyId'] ?? '';

        // 1. Zápis do SecureStorage (pre SettingsPage a rýchle overenie)
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_role', value: role);
        await _storage.write(key: 'company_code', value: companyId);

        // 2. Zápis do lokálnej SQLite (Drift) pre prácu s médiami
        await _localDb.upsertUser(UsersCompanion(
          uid: Value(uid),
          email: Value(email),
          role: Value(role),
          companyCode: Value(companyId),
        ));

        print("✅ Dáta synchronizované: SecureStorage aj SQLite");
      }
    } catch (e) {
      print("❌ Chyba pri synchronizácii: $e");
    }
  }

  // --- 1. REGISTRÁCIA ADMINA ---
  Future<String?> registerAdminAndCompany({
    required String email,
    required String password,
    required String companyName,
    required String ico,
  }) async {
    try {
      fb.UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      fb.User? user = res.user;

      if (user != null) {
        String inviteCode = _generateInviteCode();

        DocumentReference companyRef = await _db.collection('companies').add({
          'name': companyName,
          'ico': ico,
          'inviteCode': inviteCode,
          'adminUid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': 'admin',
          'companyId': companyRef.id,
          'companyName': companyName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await syncUserToSecureStorage(user.uid);
        return inviteCode;
      }
    } catch (e) {
      print("❌ Chyba pri registrácii admina: $e");
      rethrow;
    }
    return null;
  }

  // --- 2. PRIHLÁSENIE ---
  Future<fb.UserCredential> signIn(String email, String password) async {
    try {
      fb.UserCredential res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (res.user != null) {
        await syncUserToSecureStorage(res.user!.uid);
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. REGISTRÁCIA TECHNIKA ---
  Future<void> registerTechnician({
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    try {
      var companyQuery = await _db
          .collection('companies')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (companyQuery.docs.isEmpty) {
        throw Exception("Tento kód je neplatný.");
      }

      var companyDoc = companyQuery.docs.first;
      String companyId = companyDoc.id;
      String companyName = companyDoc.get('name');

      fb.UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (res.user != null) {
        await _db.collection('users').doc(res.user!.uid).set({
          'uid': res.user!.uid,
          'email': email,
          'role': 'technician',
          'companyId': companyId,
          'companyName': companyName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Kód sa "spotrebuje"
        await _db.collection('companies').doc(companyId).update({
          'inviteCode': FieldValue.delete(),
        });

        await syncUserToSecureStorage(res.user!.uid);
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- ODHLÁSENIE ---
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'company_code');
  }

  // --- POMOCNÉ METÓDY ---

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  Future<DocumentSnapshot?> getCompanyData() async {
    fb.User? user = _auth.currentUser;
    if (user == null) return null;
    DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;
    String companyId = userDoc.get('companyId');
    return await _db.collection('companies').doc(companyId).get();
  }

  Future<String> regenerateInviteCode(String companyId) async {
    String newCode = _generateInviteCode();
    await _db.collection('companies').doc(companyId).update({
      'inviteCode': newCode,
    });
    return newCode;
  }

  Stream<QuerySnapshot> getCompanyEmployees(String companyId) {
    return _db
        .collection('users')
        .where('companyId', isEqualTo: companyId)
        .where('role', isEqualTo: 'technician')
        .snapshots();
  }

  Future<String?> getUserRole(String uid) async {
    // 1. Skúsime lokálnu SQLite (User tu pochádza z database.dart)
    final User? localUser = await _localDb.getUser(uid);
    if (localUser != null) return localUser.role;

    // 2. Ak nie je lokálne, ideme do cloudu
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      String role = doc.get('role');
      await syncUserToSecureStorage(uid);
      return role;
    }
    return null;
  }

  fb.User? get currentUser => _auth.currentUser;
}
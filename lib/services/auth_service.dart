import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'package:drift/drift.dart';
import '../database.dart'; // Uisti sa, že cesta je správna

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // OPRAVA DRIFT: Databázu už nevytvárame tu, ale dostaneme ju zvonku
  final AppDatabase _localDb;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // KONŠTRUKTOR: Musíš ho zavolať s inštanciou databázy
  AuthService(this._localDb);

  // --- SYNCHRONIZÁCIA ---
  Future<void> syncUserToSecureStorage(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final String email = data['email'] ?? '';
        final String role = data['role'] ?? '';
        final String companyId = data['companyId'] ?? '';

        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_role', value: role);
        await _storage.write(key: 'company_id', value: companyId);

        // Zápis do Drift (SQLite)
        await _localDb.upsertUser(UsersCompanion(
          uid: Value(uid),
          email: Value(email),
          role: Value(role),
          companyCode: Value(companyId),
        ));

        print("✅ Synchronizácia úspešná");
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
      print("❌ Chyba admin registrácie: $e");
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

  // --- 3. REGISTRÁCIA TECHNIKA (OPRAVENÁ LOGIKA) ---
  Future<void> registerTechnician({
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    fb.UserCredential? res;
    try {
      // KROK A: Najprv vytvoríme Auth účet (tým sa user prihlási a Rules ho pustia)
      res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (res.user != null) {
        // KROK B: Teraz, keď je prihlásený, skontrolujeme kód vo Firestore
        var companyQuery = await _db
            .collection('companies')
            .where('inviteCode', isEqualTo: inviteCode)
            .limit(1)
            .get();

        // KROK C: Ak kód neexistuje, zmažeme čerstvo vytvorený Auth účet
        if (companyQuery.docs.isEmpty) {
          await res.user!.delete();
          throw Exception("Tento pozývací kód je neplatný.");
        }

        var companyDoc = companyQuery.docs.first;
        String companyId = companyDoc.id;
        String companyName = companyDoc.get('name');

        // KROK D: Všetko OK, zapíšeme profil do Firestore
        await _db.collection('users').doc(res.user!.uid).set({
          'uid': res.user!.uid,
          'email': email,
          'role': 'technician',
          'companyId': companyId,
          'companyName': companyName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Kód sa "spotrebuje" (zmaže sa z firmy)
        await _db.collection('companies').doc(companyId).update({
          'inviteCode': FieldValue.delete(),
        });

        await syncUserToSecureStorage(res.user!.uid);
      }
    } catch (e) {
      // Ak nastala chyba pri hľadaní kódu alebo zápise, a user už bol vytvorený, zmažeme ho
      if (res?.user != null) {
        try { await res!.user!.delete(); } catch (_) {}
      }
      rethrow;
    }
  }

  // --- OSTATNÉ METÓDY ---

  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'company_id');
  }

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
    final User? localUser = await _localDb.getUser(uid);
    if (localUser != null) return localUser.role;

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
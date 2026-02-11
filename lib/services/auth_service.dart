import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. REGISTRÁCIA ADMINA (ZAKLADATEĽ FIRMY) ---
  Future<void> registerAdminAndCompany({
    required String email,
    required String password,
    required String companyName,
    required String ico,
  }) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = res.user;

      if (user != null) {
        String inviteCode = _generateInviteCode();

        // A. Vytvoríme dokument FIRMY
        DocumentReference companyRef = await _db.collection('companies').add({
          'name': companyName,
          'ico': ico,
          'inviteCode': inviteCode, // Tento kód Admin dá technikom
          'adminUid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // B. Vytvoríme dokument POUŽÍVATEĽA (Admina)
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': 'admin',
          'companyId': companyRef.id,
          'companyName': companyName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("✅ Firma vytvorená. ID: ${companyRef.id}, Kód: $inviteCode");
      }
    } catch (e) {
      print("❌ Chyba pri registrácii admina: $e");
      rethrow;
    }
  }

  // --- 2. REGISTRÁCIA TECHNIKA (PRIDANIE SA K FIRME) ---
// services/auth_service.dart

  Future<void> registerTechnician({
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    try {
      // 1. Nájdeme firmu podľa kódu
      var companyQuery = await _db
          .collection('companies')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (companyQuery.docs.isEmpty) {
        throw Exception("Tento kód je neplatný alebo už bol použitý.");
      }

      var companyDoc = companyQuery.docs.first;
      String companyId = companyDoc.id;
      String companyName = companyDoc.get('name');

      // 2. Vytvoríme používateľa v Auth
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (res.user != null) {
        // 3. Priradíme ho k firme
        await _db.collection('users').doc(res.user!.uid).set({
          'uid': res.user!.uid,
          'email': email,
          'role': 'technician',
          'companyId': companyId,
          'companyName': companyName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // ⭐ KĽÚČOVÝ KROK: Zneplatníme kód vo firme (nastavíme ho na prázdny alebo null)
        await _db.collection('companies').doc(companyId).update({
          'inviteCode': FieldValue.delete(), // Kód zmizne z DB
        });

        print("✅ Technik pridaný a kód bol spotrebovaný.");
      }
    } catch (e) {
      print("❌ Chyba: $e");
      rethrow;
    }
  }
  // --- 3. POMOCNÁ FUNKCIA: Generátor kódu ---
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  // --- 4. ODHLÁSENIE ---
  Future<void> signOut() async {
    await _auth.signOut();
  }


  // Pridaj do triedy AuthService v services/auth_service.dart

// Získanie údajov o firme (vrátane inviteCode)
  Future<DocumentSnapshot?> getCompanyData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    // Najprv zistíme companyId z dokumentu používateľa
    DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;

    String companyId = userDoc.get('companyId');
    return await _db.collection('companies').doc(companyId).get();
  }

// Pregenerovanie kódu
  Future<String> regenerateInviteCode(String companyId) async {
    String newCode = _generateInviteCode();
    await _db.collection('companies').doc(companyId).update({
      'inviteCode': newCode,
    });
    return newCode;
  }

  // Pridaj do triedy AuthService v services/auth_service.dart

  Stream<QuerySnapshot> getCompanyEmployees(String companyId) {
    return _db
        .collection('users')
        .where('companyId', isEqualTo: companyId)
        .where('role', isEqualTo: 'technician') // Chceme vidieť len technikov, nie seba
        .snapshots();
  }

  // --- 5. ZÍSKANIE ROLE POUŽÍVATEĽA (Dôležité pre main.dart) ---
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.get('role');
    }
    return null;
  }

  User? get currentUser => _auth.currentUser;
}
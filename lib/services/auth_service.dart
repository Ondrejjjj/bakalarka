import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. REGISTRÁCIA ADMINA A FIRMY
  Future<void> registerAdminAndCompany({
    required String email,
    required String password,
    required String companyName,
    required String ico,
  }) async {
    try {
      // Vytvorenie používateľa v Authentication
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = res.user;

      if (user != null) {
        // Vygenerujeme unikátny 6-miestny kód (napr. AB12CD)
        String inviteCode = _generateInviteCode();

        // A. Vytvoríme dokument FIRMY v kolekcii 'companies'
        DocumentReference companyRef = await _db.collection('companies').add({
          'name': companyName,
          'ico': ico,
          'inviteCode': inviteCode,
          'adminUid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // B. Vytvoríme dokument POUŽÍVATEĽA v kolekcii 'users'
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': 'admin',
          'companyId': companyRef.id, // Prepojenie na firmu cez jej ID
          'companyName': companyName,
        });

        print("✅ Účet a firma vytvorená. Kód: $inviteCode");
      }
    } catch (e) {
      print("❌ Chyba pri registrácii: $e");
      rethrow;
    }
  }

  // 2. POMOCNÁ FUNKCIA: Generátor kódu
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Bez 0, O, I, 1 pre čitateľnosť
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  // 3. ODHLÁSENIE
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 4. ZÍSKANIE AKTUÁLNEHO POUŽÍVATEĽA
  User? get currentUser => _auth.currentUser;
}
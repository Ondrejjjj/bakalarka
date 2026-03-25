import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Funkcia na synchronizáciu lokálneho súboru do cloudu (Upload)
  Future<bool> uploadMedia(File localFile, String type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("❌ Chyba: Používateľ nie je prihlásený.");
        return false;
      }

      // 1. Získanie informácií o firme používateľa z Firestore
      DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        print("❌ Chyba: Dokument používateľa neexistuje.");
        return false;
      }

      String companyId = userDoc.get('companyId');
      String companyName = userDoc.get('companyName');

      // 2. Vytvorenie unikátneho názvu súboru
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}';
      String extension = type == 'image' ? '.jpg' : (type == 'video' ? '.mp4' : '.m4a');
      String fullPath = 'companies/$companyId/media/$fileName$extension';

      // 3. Odkaz na Firebase Storage
      Reference ref = _storage.ref().child(fullPath);

      // 4. Nahranie súboru
      print("⏳ Nahrávam súbor na Storage...");
      UploadTask uploadTask = ref.putFile(localFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 5. Zápis metadát do Firestore
      await _db.collection('media_reports').add({
        'url': downloadUrl,
        'storagePath': fullPath,
        'ownerId': user.uid,
        'ownerEmail': user.email,
        'companyId': companyId,
        'companyName': companyName,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isDeletedByAdmin': false,
      });

      print("✅ Synchronizácia úspešná: $downloadUrl");
      return true;

    } catch (e) {
      print("❌ Chyba pri cloude: $e");
      return false;
    }
  }

  /// Získa zoznam všetkých nahlásených médií používateľa z Firestore (Download Info)
  /// TÁTO METÓDA MUSÍ BYŤ VNÚTRI TRIEDY CloudService
  Future<List<Map<String, dynamic>>> getUserMediaReports() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("❌ Chyba: Žiaden prihlásený používateľ.");
      return [];
    }

    try {
      print("⏳ Sťahujem zoznam reportov z Firestore...");
      QuerySnapshot snapshot = await _db
          .collection('media_reports')
          .where('ownerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Pridáme aj ID dokumentu, môže sa hodiť neskôr
        data['docId'] = doc.id;
        return data;
      }).toList();

    } catch (e) {
      print("❌ Chyba pri sťahovaní zoznamu: $e");
      return [];
    }
  }
}
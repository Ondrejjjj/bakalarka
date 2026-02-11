import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Funkcia na synchronizáciu lokálneho súboru do cloudu.
  /// [localFile] je súbor z tvojho lokálneho úložiska.
  /// [type] určuje či ide o 'image', 'video' alebo 'audio'.
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

      // 2. Vytvorenie unikátneho názvu súboru (Timestamp + UID)
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}';

      // Pridáme príponu podľa typu (voliteľné, ale prehľadnejšie v Storage)
      String extension = type == 'image' ? '.jpg' : (type == 'video' ? '.mp4' : '.m4a');
      String fullPath = 'companies/$companyId/media/$fileName$extension';

      // 3. Odkaz na Firebase Storage
      Reference ref = _storage.ref().child(fullPath);

      // 4. Nahranie súboru do Storage
      print("⏳ Nahrávam súbor na Storage...");
      UploadTask uploadTask = ref.putFile(localFile);

      // Môžeš tu sledovať progres (voliteľné pre UI neskôr)
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 5. Zápis metadát do Firestore (kolekcia media_reports)
      // Tieto dáta bude vidieť Admin v jeho galérii
      await _db.collection('media_reports').add({
        'url': downloadUrl,
        'storagePath': fullPath,
        'ownerId': user.uid,
        'ownerEmail': user.email,
        'companyId': companyId,
        'companyName': companyName,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isDeletedByAdmin': false, // Rezerva pre budúcnosť
      });

      print("✅ Synchronizácia úspešná: $downloadUrl");
      return true; // Vrátime true, aby galéria vedela, že môže označiť "Synced"

    } catch (e) {
      print("❌ Chyba pri cloude: $e");
      return false;
    }
  }
}
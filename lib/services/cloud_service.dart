import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CloudService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Nahranie média na Firebase Storage + zápis metadát do Firestore
  Future<bool> uploadMedia(File localFile, String type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // 1. Získanie info o používateľovi (aby sme vedeli, do ktorej firmy súbor patrí)
      DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      String companyId = userData['companyId'] ?? 'unknown';
      String companyName = userData['companyName'] ?? 'Neznáma firma';
      // Získame aj meno používateľa pre SyncService
      String ownerName = userData['name'] ?? user.email?.split('@').first ?? 'Používateľ';

      // 2. Cesta k súboru
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}';
      // Oprava prípony pre audio (m4a je štandard pre Flutter Sound/Record)
      String extension = type == 'image' ? '.jpg' : (type == 'video' ? '.mp4' : '.m4a');
      String fullPath = 'companies/$companyId/media/$fileName$extension';

      // 3. Nahrávanie na Storage
      Reference ref = _storage.ref().child(fullPath);

      // Pridáme metadata k súboru (dobré pre prehľad v konzole)
      SettableMetadata metadata = SettableMetadata(contentType: '$type/${extension.replaceFirst('.', '')}');

      debugPrint("⏳ Nahrávam $type na Storage: $fullPath");
      UploadTask uploadTask = ref.putFile(localFile, metadata);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Zápis do Firestore (Tieto polia musí SyncService vedieť prečítať!)
      await _db.collection('media_reports').add({
        'url': downloadUrl,
        'storagePath': fullPath,
        'ownerId': user.uid,
        'ownerEmail': user.email,
        'ownerName': ownerName, // Pridané pre SyncService
        'companyId': companyId,
        'companyName': companyName,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isDeletedByAdmin': false,
        'deviceId': 'mobile_app', // Užitočné pri debugovaní
      });

      debugPrint("✅ Synchronizácia úspešná.");
      return true;

    } catch (e) {
      debugPrint("❌ Chyba pri cloude (Upload): $e");
      return false;
    }
  }

  /// Získanie zoznamu reportov (Pre potreby zobrazenia v UI)
  Future<List<Map<String, dynamic>>> getUserMediaReports() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Najprv zistíme companyId prihláseného usera
      DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
      String companyId = userDoc.get('companyId');

      debugPrint("⏳ Sťahujem reporty pre firmu: $companyId");

      // Dotaz: Moje reporty v rámci mojej aktuálnej firmy
      QuerySnapshot snapshot = await _db
          .collection('media_reports')
          .where('companyId', isEqualTo: companyId) // Bezpečnostný filter
          .where('ownerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();

    } catch (e) {
      debugPrint("❌ Chyba pri sťahovaní zoznamu: $e");
      return [];
    }
  }
}
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

      // 1. Získanie info o používateľovi
      DocumentSnapshot userDoc =
      await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;

      // users dokument má pole 'companyId' – čítame ho a ukladáme ako 'companyCode'
      // aby SyncService a Firestore rules vedeli dokument nájsť
      final String companyCode =
          (userData['companyCode'] as String?) ??
              (userData['companyId'] as String?) ??
              'unknown';
      final String companyName =
          (userData['companyName'] as String?) ?? 'Neznáma firma';
      final String ownerName =
          (userData['name'] as String?) ??
              user.email?.split('@').first ??
              'Používateľ';

      // 2. Cesta k súboru na Firebase Storage
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${user.uid}';
      final String extension =
      type == 'image' ? '.jpg' : (type == 'video' ? '.mp4' : '.m4a');
      final String fullPath =
          'companies/$companyCode/media/$fileName$extension';

      // 3. Nahrávanie na Storage
      final Reference ref = _storage.ref().child(fullPath);
      final SettableMetadata metadata = SettableMetadata(
        contentType: '$type/${extension.replaceFirst('.', '')}',
      );

      debugPrint('⏳ Nahrávam $type na Storage: $fullPath');
      final UploadTask uploadTask = ref.putFile(localFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Zápis do Firestore
      // DÔLEŽITÉ: názvy polí musia byť zhodné s tým čo číta SyncService:
      //   'userEmail'   – SyncService číta report['userEmail']
      //   'companyCode' – SyncService a Firestore rules čítajú 'companyCode'
      await _db.collection('media_reports').add({
        'url':              downloadUrl,
        'storagePath':      fullPath,
        'ownerId':          user.uid,
        'userEmail':        user.email,   // ← oprava: bolo 'ownerEmail'
        'ownerName':        ownerName,
        'companyCode':      companyCode,  // ← oprava: bolo 'companyId'
        'companyName':      companyName,
        'type':             type,
        'createdAt':        FieldValue.serverTimestamp(),
        'isDeletedByAdmin': false,
        'deviceId':         'mobile_app',
      });

      debugPrint('✅ Synchronizácia úspešná: $fullPath');
      return true;
    } catch (e) {
      debugPrint('❌ Chyba pri cloude (Upload): $e');
      return false;
    }
  }

  /// Získanie zoznamu médií pre prihláseného používateľa
  Future<List<Map<String, dynamic>>> getUserMediaReports() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final DocumentSnapshot userDoc =
      await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final String companyCode =
          (userData['companyCode'] as String?) ??
              (userData['companyId'] as String?) ??
              '';

      debugPrint('⏳ Sťahujem reporty pre firmu: $companyCode');

      // Filtrujeme podľa companyCode a userEmail
      final QuerySnapshot snapshot = await _db
          .collection('media_reports')
          .where('companyCode', isEqualTo: companyCode)
          .where('userEmail', isEqualTo: user.email)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Chyba pri sťahovaní zoznamu: $e');
      return [];
    }
  }
}
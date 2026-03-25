import 'dart:convert';
import 'dart:io';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/services/cloud_service.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart';

class SyncService {
  final AppDatabase db;
  final CloudService cloud = CloudService();
  final _storage = const FlutterSecureStorage();

  SyncService(this.db);

  /// Kontrola, či už úvodná synchronizácia prebehla pre KONKRÉTNEHO používateľa
  /// Používame email v kľúči, aby sa to pri prehlásení iného človeka nepobilo
  Future<bool> isInitialSyncRequired(String email) async {
    if (email.isEmpty) return false;
    String? status = await _storage.read(key: 'sync_done_$email');
    return status == null;
  }

  /// Označenie, že synchronizácia je pre daného používateľa navždy hotová
  Future<void> markInitialSyncAsDone(String email) async {
    if (email.isEmpty) return;
    await _storage.write(key: 'sync_done_$email', value: 'true');
  }

  /// 1. UPLOAD: Nahrávanie na Firebase
  Future<bool> syncMedia(File encryptedFile, String type) async {
    File? tempFile;
    try {
      if (!await encryptedFile.exists()) return false;

      final bytes = await encryptedFile.readAsBytes();
      final decryptedBytes = await CryptoService.decryptBytes(bytes);

      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/temp_sync_${DateTime.now().millisecondsSinceEpoch}');
      await tempFile.writeAsBytes(decryptedBytes);

      bool success = await cloud.uploadMedia(tempFile, type);

      if (success) {
        if (type == 'image') await db.markPhotoAsUploaded(encryptedFile.path);
        if (type == 'video') await db.markVideoAsUploaded(encryptedFile.path);
        if (type == 'audio') await db.markAudioAsUploaded(encryptedFile.path);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Chyba v syncMedia: $e");
      return false;
    } finally {
      if (tempFile != null && await tempFile.exists()) await tempFile.delete();
    }
  }

  /// 2. RESTORE: Kompletná obnova (spustí sa len RAZ za život aplikácie/účtu)
  Future<void> restoreAllUserData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Načítanie identity z pamäte
      final currentEmail = await _storage.read(key: 'user_email') ?? '';

      // EXTRA POISTKA: Ak už v pamäti svieti, že sync prebehol, okamžite končíme a ani nezačíname query
      if (!(await isInitialSyncRequired(currentEmail))) {
        debugPrint("Restore pre $currentEmail už bol v minulosti vykonaný. Preskakujem.");
        return;
      }

      final companyId = await _storage.read(key: 'company_code') ?? '';
      final userRole = await _storage.read(key: 'user_role') ?? 'user';
      final isAdmin = userRole == 'admin';

      debugPrint(" Štart JEDNORAZOVEJ obnovy dát pre: $currentEmail");

      final directory = await getApplicationDocumentsDirectory();

      // --- A. MÉDIÁ ---
      final mediaQuery = await firestore.collection('media_reports')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in mediaQuery.docs) {
        try {
          final report = doc.data();
          String ownerEmail = report['ownerEmail'] ?? '';

          if (!isAdmin && ownerEmail != currentEmail) continue;

          String type = report['type'] ?? 'image';
          String url = report['url'] ?? '';
          String storagePath = report['storagePath'] ?? '';
          String deviceId = report['deviceId'] ?? 'unknown_device';


          String fileName = storagePath.split('/').last;
          if (fileName.isEmpty) fileName = '${doc.id}.enc';
          String localPath = '${directory.path}/$fileName';

          // Sťahujeme len ak súbor fyzicky nemáme
          if (!await File(localPath).exists()) {
            final httpClient = HttpClient();
            final request = await httpClient.getUrl(Uri.parse(url));
            final response = await request.close();
            final bytes = await consolidateHttpClientResponseBytes(response);

            final encryptedBytes = await CryptoService.encryptBytes(bytes);
            await File(localPath).writeAsBytes(encryptedBytes);
          }

          if (type == 'image') {
            await db.insertPhoto(
              filePath: localPath,
              userEmail: ownerEmail,
              companyCode: companyId,
              ownerName: report['ownerName'] ?? report['companyName'] ?? 'Obnovené',
              uploaded: true,
              deviceId: deviceId,
            );
          } else if (type == 'video') {
            await db.insertVideo(
              filePath: localPath,
              userEmail: ownerEmail,
              companyCode: companyId,
              ownerName: report['ownerName'] ?? report['companyName'] ?? 'Obnovené',
              uploaded: true,
              deviceId: deviceId,
            );
          }
        } catch (e) {
          debugPrint("⚠️ Chyba pri médiu ${doc.id}: $e");
        }
      }

      // --- B. SKLAD (Inventory) ---
      final inventoryDocs = await firestore.collection('inventory')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in inventoryDocs.docs) {
        try {
          final data = doc.data();
          String ownerEmail = data['ownerEmail'] ?? currentEmail;
          if (!isAdmin && ownerEmail != currentEmail) continue;

          await db.upsertInventoryItem(InventoryCompanion.insert(
            firebaseId: Value(doc.id),
            name: data['name'] ?? '',
            sku: data['sku'] ?? '',
            ean: data['ean'] ?? '',
            unit: data['unit'] ?? 'ks',
            qty: Value((data['qty'] ?? 0.0).toDouble()),
            userEmail: ownerEmail,
            companyCode: companyId,
            isUploaded: const Value(true),
          ));
        } catch (e) {
          debugPrint("⏭️ Preskakujem Inventory duplikát.");
        }
      }

      // --- C. MAJETOK (Assets) ---
      final assetDocs = await firestore.collection('assets')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in assetDocs.docs) {
        try {
          final data = doc.data();
          String ownerEmail = data['ownerEmail'] ?? currentEmail;
          if (!isAdmin && ownerEmail != currentEmail) continue;

          await db.upsertAsset(AssetsCompanion.insert(
            firebaseId: Value(doc.id),
            name: data['name'] ?? 'Neznámy majetok',
            sn: data['sn'] ?? '',
            model: data['model'] ?? '',
            status: data['status'] ?? 'V prevádzke',
            techSpecs: data['techSpecs'] is Map ? jsonEncode(data['techSpecs']) : (data['techSpecs'] ?? '{}'),
            history: data['history'] is List ? jsonEncode(data['history']) : (data['history'] ?? '[]'),
            userEmail: ownerEmail,
            companyCode: companyId,
            isUploaded: const Value(true),
          ));
        } catch (e) {
          debugPrint("⏭️ Preskakujem Asset duplikát.");
        }
      }


      await markInitialSyncAsDone(currentEmail);
      debugPrint("✅ Úvodná obnova navždy dokončená pre $currentEmail.");
    } catch (e) {
      debugPrint("❌ Kritická chyba pri synchronizácii: $e");
    }
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/services/cloud_service.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' hide Query;

class SyncService {
  final AppDatabase db;
  final CloudService cloud = CloudService();
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  SyncService(this.db);

  // 1. STAV SYNCHRONIZÁCIE

  Future<bool> isInitialSyncRequired(String email) async {
    if (email.isEmpty) return false;
    final status = await _storage.read(key: 'sync_done_$email');
    return status == null;
  }

  Future<void> markInitialSyncAsDone(String email) async {
    if (email.isEmpty) return;
    await _storage.write(key: 'sync_done_$email', value: 'true');
  }

  // 2. POMOCNÉ METÓDY – BEZPEČNÉ VKLADANIE (bez duplikátov)

  Future<void> _upsertPhoto({
    required String filePath,
    required String userEmail,
    required String companyCode,
    required String deviceId,
    String? ownerName,
    bool uploaded = false,
    double? latitude,
    double? longitude,
  }) async {
    final existing = await (db.select(db.photos)
      ..where((p) => p.filePath.equals(filePath)))
        .getSingleOrNull();
    if (existing != null) return;
    await db.insertPhoto(
      filePath: filePath,
      userEmail: userEmail,
      companyCode: companyCode,
      deviceId: deviceId,
      ownerName: ownerName,
      uploaded: uploaded,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> _upsertVideo({
    required String filePath,
    required String userEmail,
    required String companyCode,
    required String deviceId,
    String? ownerName,
    bool uploaded = false,
    int? duration,
  }) async {
    final existing = await (db.select(db.videos)
      ..where((v) => v.filePath.equals(filePath)))
        .getSingleOrNull();
    if (existing != null) return;
    await db.insertVideo(
      filePath: filePath,
      userEmail: userEmail,
      companyCode: companyCode,
      deviceId: deviceId,
      ownerName: ownerName,
      uploaded: uploaded,
      duration: duration,
    );
  }

  Future<void> _upsertAudio({
    required String filePath,
    required String userEmail,
    required String companyCode,
    required String deviceId,
    String? ownerName,
    bool uploaded = false,
    int? duration,
  }) async {
    final existing = await (db.select(db.audios)
      ..where((a) => a.filePath.equals(filePath)))
        .getSingleOrNull();
    if (existing != null) return;
    await db.insertAudio(
      filePath: filePath,
      userEmail: userEmail,
      companyCode: companyCode,
      deviceId: deviceId,
      ownerName: ownerName,
      uploaded: uploaded,
      duration: duration,
    );
  }

  // ---------------------------------------------------------------------------
  // 3. STIAHNUTIE A ZAŠIFROVANIE MÉDIA
  // ---------------------------------------------------------------------------

  Future<void> _downloadAndEncryptMedia(String url, String localPath) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      final encryptedBytes = await CryptoService.encryptBytes(bytes);
      await File(localPath).writeAsBytes(encryptedBytes);
    } catch (e) {
    }
  }



  Future<bool> syncMedia(File encryptedFile, String type) async {
    File? tempFile;
    try {
      if (!await encryptedFile.exists()) return false;

      final bytes = await encryptedFile.readAsBytes();
      final decryptedBytes = await CryptoService.decryptBytes(bytes);

      final tempDir = await getTemporaryDirectory();
      tempFile = File(
          '${tempDir.path}/temp_sync_${DateTime.now().millisecondsSinceEpoch}');
      await tempFile.writeAsBytes(decryptedBytes);

      final success = await cloud.uploadMedia(tempFile, type);

      if (success) {
        if (type == 'image') await db.markPhotoAsUploaded(encryptedFile.path);
        if (type == 'video') await db.markVideoAsUploaded(encryptedFile.path);
        if (type == 'audio') await db.markAudioAsUploaded(encryptedFile.path);
        return true;
      }
      return false;
    } catch (e) {

      return false;
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  // 5. RESTORE – JEDNORAZOVÁ OBNOVA PRI NOVEJ INŠTALÁCII / PREINŠTALOVANÍ

  Future<int?> _findInventoryIdByName(String name, String companyCode) async {
    if (name.isEmpty) return null;
    final item = await (db.select(db.inventory)
      ..where((t) => t.name.equals(name) & t.companyCode.equals(companyCode)))
        .getSingleOrNull();
    return item?.id;
  }

  Future<void> restoreAllUserData() async {
    final currentEmail = await _storage.read(key: 'user_email') ?? '';

    if (!(await isInitialSyncRequired(currentEmail))) {
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final companyId = await _storage.read(key: 'company_code') ?? '';
      final userRole = await _storage.read(key: 'user_role') ?? 'user';
      final isAdmin = userRole == 'admin';
      final directory = await getApplicationDocumentsDirectory();

      // ── A. ASSETS – celá firma (admin aj technik vidia firemný majetok) ───

      final assetDocs = await firestore
          .collection('assets')
          .where('companyCode', isEqualTo: companyId)
          .get();

      for (final doc in assetDocs.docs) {
        try {
          final data = doc.data();
          final existing = await (db.select(db.assets)
            ..where((t) =>
            t.firebaseId.equals(doc.id) |
            t.sn.equals(data['sn'] ?? '')))
              .getSingleOrNull();

          await db.into(db.assets).insertOnConflictUpdate(AssetsCompanion(
            id: existing != null ? Value(existing.id) : const Value.absent(),
            firebaseId: Value(doc.id),
            name: Value(data['name'] ?? 'Obnovený majetok'),
            sn: Value(data['sn'] ?? ''),
            model: Value(data['model'] ?? ''),
            status: Value(data['status'] ?? 'V prevádzke'),
            techSpecs: Value(data['techSpecs'] is Map
                ? jsonEncode(data['techSpecs'])
                : (data['techSpecs'] ?? '{}')),
            history: Value(data['history'] is List
                ? jsonEncode(data['history'])
                : (data['history'] ?? '[]')),
            userEmail: Value(data['userEmail'] ?? currentEmail),
            companyCode: Value(companyId),
            isUploaded: const Value(true),
          ));
        } catch (e) {

        }
      }

      // ── B. INVENTORY – celá firma ─────────────────────────────────────────

      final inventoryDocs = await firestore
          .collection('inventory')
          .where('companyCode', isEqualTo: companyId)
          .get();

      for (final doc in inventoryDocs.docs) {
        try {
          final data = doc.data();
          final existing = await (db.select(db.inventory)
            ..where((t) =>
            t.firebaseId.equals(doc.id) |
            t.ean.equals(data['ean'] ?? '')))
              .getSingleOrNull();

          await db.into(db.inventory).insertOnConflictUpdate(InventoryCompanion(
            id: existing != null ? Value(existing.id) : const Value.absent(),
            firebaseId: Value(doc.id),
            name: Value(data['name'] ?? ''),
            sku: Value(data['sku'] ?? ''),
            ean: Value(data['ean'] ?? ''),
            unit: Value(data['unit'] ?? 'ks'),
            qty: Value((data['qty'] ?? 0.0).toDouble()),
            userEmail: Value(data['userEmail'] ?? currentEmail),
            companyCode: Value(companyId),
            isUploaded: const Value(true),
          ));
        } catch (e) {
        }
      }

      // ── C. POHYBY SKLADU ──────────────────────────────────────────────────
      final moveDocs = await firestore
          .collection('movements')
          .where('companyCode', isEqualTo: companyId)
          .get();

      for (final doc in moveDocs.docs) {
        try {
          final data = doc.data();
          final existing = await (db.select(db.stockMovements)
            ..where((t) => t.firebaseId.equals(doc.id)))
              .getSingleOrNull();
          if (existing != null) continue;

          await db.into(db.stockMovements).insertOnConflictUpdate(
            StockMovementsCompanion.insert(
              firebaseId: Value(doc.id),
              inventoryId: data['inventoryId'] ?? await _findInventoryIdByName(
                  data['itemName'] ?? '', companyId) ?? 0,
              itemName: data['itemName'] ?? '',
              changeQty: (data['changeQty'] ?? 0.0).toDouble(),
              type: data['type'] ?? 'income',
              extraData: Value(data['extraData'] is Map
                  ? jsonEncode(data['extraData'])
                  : (data['extraData'] ?? '{}')),
              userEmail: data['userEmail'] ?? '',
              companyCode: companyId,
              createdAt: Value(data['createdAt'] != null
                  ? DateTime.parse(data['createdAt'])
                  : DateTime.now()),
              isUploaded: const Value(true),
            ),
          );
        } catch (e) {
        }
      }

      // ── D. MÉDIÁ ──────────────────────────────────────────────────────────


      final mediaDocs = await firestore
          .collection('media_reports')
          .where('companyCode', isEqualTo: companyId)
          .get();


      for (final doc in mediaDocs.docs) {
        try {
          final report = doc.data();
          final ownerEmail = (report['userEmail'] as String?) ?? '';

          // Technik preskočí médiá iných ľudí; admin obnoví všetko
          if (!isAdmin && ownerEmail != currentEmail) continue;

          final url = (report['url'] as String?) ?? '';
          if (url.isEmpty) continue;

          final storagePath = (report['storagePath'] as String?) ?? '';
          final type = (report['type'] as String?) ?? 'image';
          final deviceId = (report['deviceId'] as String?) ?? 'restored';
          final ownerName = (report['ownerName'] as String?) ??
              (report['companyName'] as String?) ??
              'Obnovené';

          String fileName = storagePath.split('/').last;
          if (fileName.isEmpty) fileName = '${doc.id}.enc';
          final localPath = '${directory.path}/$fileName';

          if (!await File(localPath).exists()) {
            await _downloadAndEncryptMedia(url, localPath);
          }

          // Vložím záznam do SQLite bez rizika duplikátu
          switch (type) {
            case 'image':
              await _upsertPhoto(
                filePath: localPath,
                userEmail: ownerEmail,
                companyCode: companyId,
                deviceId: deviceId,
                ownerName: ownerName,
                uploaded: true,
              );
              break;
            case 'video':
              await _upsertVideo(
                filePath: localPath,
                userEmail: ownerEmail,
                companyCode: companyId,
                deviceId: deviceId,
                ownerName: ownerName,
                uploaded: true,
              );
              break;
            case 'audio':
              await _upsertAudio(
                filePath: localPath,
                userEmail: ownerEmail,
                companyCode: companyId,
                deviceId: deviceId,
                ownerName: ownerName,
                uploaded: true,
              );
              break;
          }
        } catch (e) {

        }
      }

      await markInitialSyncAsDone(currentEmail);

    } catch (e) {

    }
  }

  // 6. LIVE SYNC – BEŽNÝ CHOD APLIKÁCIE (volaj raz po prihlásení)


  Future<void> startLiveSync() async {
    final companyId = await _storage.read(key: 'company_code') ?? '';
    final currentEmail = await _storage.read(key: 'user_email') ?? '';
    final userRole = await _storage.read(key: 'user_role') ?? 'user';
    final isAdmin = userRole == 'admin';

    if (companyId.isEmpty) {
      return;
    }


    // ── A. LIVE ASSETS ───────────────────────────────────────────────────────

    FirebaseFirestore.instance
        .collection('assets')
        .where('companyCode', isEqualTo: companyId)
        .snapshots()
        .listen((snapshot) async {
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final existing = await (db.select(db.assets)
            ..where((t) =>
            t.firebaseId.equals(doc.id) | t.sn.equals(data['sn'] ?? '')))
              .getSingleOrNull();

          await db.into(db.assets).insertOnConflictUpdate(AssetsCompanion(
            id: existing != null ? Value(existing.id) : const Value.absent(),
            firebaseId: Value(doc.id),
            name: Value(data['name'] ?? ''),
            sn: Value(data['sn'] ?? ''),
            model: Value(data['model'] ?? ''),
            status: Value(data['status'] ?? ''),
            techSpecs: Value(data['techSpecs'] is Map
                ? jsonEncode(data['techSpecs'])
                : (data['techSpecs'] ?? '{}')),
            history: Value(data['history'] is List
                ? jsonEncode(data['history'])
                : (data['history'] ?? '[]')),
            userEmail: Value(data['userEmail'] ?? ''),
            companyCode: Value(companyId),
            isUploaded: const Value(true),
          ));
        } catch (e) {
        }
      }
    });

    // ── B. LIVE INVENTORY ────────────────────────────────────────────────────

    FirebaseFirestore.instance
        .collection('inventory')
        .where('companyCode', isEqualTo: companyId)
        .snapshots()
        .listen((snapshot) async {
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final existing = await (db.select(db.inventory)
            ..where((t) =>
            t.firebaseId.equals(doc.id) |
            t.ean.equals(data['ean'] ?? '')))
              .getSingleOrNull();

          await db.into(db.inventory).insertOnConflictUpdate(InventoryCompanion(
            id: existing != null ? Value(existing.id) : const Value.absent(),
            firebaseId: Value(doc.id),
            name: Value(data['name'] ?? ''),
            sku: Value(data['sku'] ?? ''),
            ean: Value(data['ean'] ?? ''),
            unit: Value(data['unit'] ?? 'ks'),
            qty: Value((data['qty'] ?? 0.0).toDouble()),
            userEmail: Value(data['userEmail'] ?? ''),
            companyCode: Value(companyId),
            isUploaded: const Value(true),
          ));
        } catch (e) {
        }
      }
    });

    // ── C. LIVE POHYBY SKLADU ────────────────────────────────────────────────

    FirebaseFirestore.instance
        .collection('movements')
        .where('companyCode', isEqualTo: companyId)
        .snapshots()
        .listen((snapshot) async {
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final existing = await (db.select(db.stockMovements)
            ..where((t) => t.firebaseId.equals(doc.id)))
              .getSingleOrNull();
          if (existing != null) continue;

          await db.into(db.stockMovements).insertOnConflictUpdate(
            StockMovementsCompanion.insert(
              firebaseId: Value(doc.id),
              inventoryId: data['inventoryId'] ?? 0,
              itemName: data['itemName'] ?? '',
              changeQty: (data['changeQty'] ?? 0.0).toDouble(),
              type: data['type'] ?? 'income',
              extraData: Value(data['extraData'] is Map
                  ? jsonEncode(data['extraData'])
                  : (data['extraData'] ?? '{}')),
              userEmail: data['userEmail'] ?? '',
              companyCode: companyId,
              createdAt: Value(data['createdAt'] != null
                  ? DateTime.parse(data['createdAt'])
                  : DateTime.now()),
              isUploaded: const Value(true),
            ),
          );
        } catch (e) {

        }
      }
    });

    // ── D. LIVE MÉDIÁ ────────────────────────────────────────────────────────

    Query<Map<String, dynamic>> mediaQuery = FirebaseFirestore.instance
        .collection('media_reports')
        .where('companyCode', isEqualTo: companyId);

    if (!isAdmin) {
      mediaQuery = mediaQuery.where('userEmail', isEqualTo: currentEmail);
    }

    final directory = await getApplicationDocumentsDirectory();

    mediaQuery.snapshots().listen((snapshot) async {
      for (final doc in snapshot.docs) {
        try {
          final report = doc.data();
          final ownerEmail = (report['userEmail'] as String?) ?? '';
          final url = (report['url'] as String?) ?? '';
          if (url.isEmpty) continue;

          if (ownerEmail == currentEmail) continue;

          final storagePath = (report['storagePath'] as String?) ?? '';
          final type = (report['type'] as String?) ?? 'image';
          final deviceId = (report['deviceId'] as String?) ?? 'live';
          final ownerName = (report['ownerName'] as String?) ??
              (report['companyName'] as String?) ??
              'Live';

          String fileName = storagePath.split('/').last;
          if (fileName.isEmpty) fileName = '${doc.id}.enc';
          final localPath = '${directory.path}/$fileName';

          if (!await File(localPath).exists()) {
            await _downloadAndEncryptMedia(url, localPath);
          }

          switch (type) {
            case 'image':
              await _upsertPhoto(
                filePath: localPath,
                userEmail: ownerEmail,
                companyCode: companyId,
                deviceId: deviceId,
                ownerName: ownerName,
                uploaded: true,
              );
              break;
            case 'video':
              await _upsertVideo(
                filePath: localPath,
                userEmail: ownerEmail,
                companyCode: companyId,
                deviceId: deviceId,
                ownerName: ownerName,
                uploaded: true,
              );
              break;
            case 'audio':
              await _upsertAudio(
                filePath: localPath,
                userEmail: ownerEmail,
                companyCode: companyId,
                deviceId: deviceId,
                ownerName: ownerName,
                uploaded: true,
              );
              break;
          }
        } catch (e) {
        }
      }
    });
  }
}
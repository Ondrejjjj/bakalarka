import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../security/crypto_service.dart';
import '../services/sync_service.dart';
import 'fullscreen_image_page.dart';
import 'package:bakalarka/database.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late AppDatabase db;
  bool _showOnlyFavorites = false;
  final Set<File> _selectedFiles = {};
  bool _selectionMode = false;
  bool _isSyncing = false;

  // Cache pre filtrovanie
  String? _currentUserEmail;
  String? _currentUserRole;
  String? _currentCompanyCode; // PRIDANÉ

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  void initState() {
    super.initState();
    _loadUserIdentity();
  }

  Future<void> _loadUserIdentity() async {
    final email = await _storage.read(key: 'user_email');
    final role = await _storage.read(key: 'user_role');
    final company = await _storage.read(key: 'company_code'); // PRIDANÉ

    if (mounted) {
      setState(() {
        _currentUserEmail = email;
        _currentUserRole = role;
        _currentCompanyCode = company;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<AppDatabase>(context);
  }

  // --- UPRAVENÝ STREAM POUŽÍVAJÚCI NOVÉ METÓDY Z DATABASE.DART ---
  Stream<List<_PhotoItem>> _watchPhotos() {
    if (_currentUserEmail == null || _currentCompanyCode == null) {
      return Stream.value([]);
    }

    // Výber správneho streamu podľa roly
    final Stream<List<Photo>> photoStream;
    if (_currentUserRole == 'admin') {
      photoStream = db.watchCompanyPhotos(_currentCompanyCode!);
    } else {
      photoStream = db.watchUserPhotos(_currentUserEmail!);
    }

    return photoStream.asyncMap((rows) async {
      final List<_PhotoItem> items = [];
      for (var row in rows) {
        final file = File(row.filePath);
        if (await file.exists()) {
          items.add(_PhotoItem(
            file: file,
            isFavorite: row.favorite,
            isUploaded: row.uploaded,
            ownerName: row.ownerName,
            latitude: row.latitude,
            longitude: row.longitude,
          ));
        }
      }
      if (_showOnlyFavorites) {
        return items.where((e) => e.isFavorite).toList();
      }
      return items;
    });
  }

  Future<Uint8List> _decryptForDisplay(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return await CryptoService.decryptBytes(bytes);
    } catch (e) {
      debugPrint("Chyba dešifrovania: $e");
      rethrow;
    }
  }

  void _toggleSelection(File file) {
    setState(() {
      if (_selectedFiles.contains(file)) {
        _selectedFiles.remove(file);
        if (_selectedFiles.isEmpty) _selectionMode = false;
      } else {
        _selectedFiles.add(file);
        _selectionMode = true;
      }
    });
  }

  void _syncSelected() async {
    setState(() => _isSyncing = true);
    final syncService = SyncService(db);
    int successCount = 0;

    for (var file in _selectedFiles) {
      bool ok = await syncService.syncMedia(file, 'image');
      if (ok) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Úspešne nahraných $successCount fotiek.')),
      );
      setState(() {
        _isSyncing = false;
        _selectedFiles.clear();
        _selectionMode = false;
      });
    }
  }

  void _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vymazať výber?'),
        content: Text('Naozaj chcete vymazať ${_selectedFiles.length} položiek?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zrušiť')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Vymazať', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      for (var file in _selectedFiles) {
        if (await file.exists()) {
          await file.delete();
          await db.deletePhoto(file.path);
        }
      }
      setState(() {
        _selectedFiles.clear();
        _selectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectionMode)
          Container(
            color: Theme.of(context).colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${_selectedFiles.length} vybrané', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_isSyncing)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    icon: const Icon(Icons.cloud_upload, color: Colors.blue),
                    onPressed: _syncSelected,
                    tooltip: 'Nahrať do cloudu',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _isSyncing ? null : _deleteSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _selectedFiles.clear();
                    _selectionMode = false;
                  }),
                ),
              ],
            ),
          ),

        Expanded(
          child: StreamBuilder<List<_PhotoItem>>(
            stream: _watchPhotos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final items = snapshot.data ?? [];
              if (items.isEmpty) return const Center(child: Text('Trezor fotiek je prázdny'));

              return GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = _selectedFiles.contains(item.file);

                  return GestureDetector(
                    onLongPress: () => _toggleSelection(item.file),
                    onTap: () async {
                      if (_selectionMode) {
                        _toggleSelection(item.file);
                      } else {
                        final bytes = await _decryptForDisplay(item.file);
                        if (!mounted) return;
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => FullscreenImagePage(
                            imageBytes: bytes, photoName: item.ownerName ?? 'Neznámy',
                            latitude: item.latitude, longitude: item.longitude,
                          ),
                        ));
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FutureBuilder<Uint8List>(
                          future: _decryptForDisplay(item.file),
                          builder: (context, thumbSnapshot) {
                            if (!thumbSnapshot.hasData) return Container(color: Colors.black12);
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(thumbSnapshot.data!, fit: BoxFit.cover),
                            );
                          },
                        ),
                        if (isSelected) Container(color: Colors.black54, child: const Icon(Icons.check_circle, color: Colors.blue, size: 32)),

                        Positioned(
                          top: 4, left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4)),
                            child: Icon(
                              item.isUploaded ? Icons.cloud_done : Icons.cloud_off,
                              color: item.isUploaded ? Colors.greenAccent : Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: -4, right: -4,
                          child: IconButton(
                            icon: Icon(item.isFavorite ? Icons.favorite : Icons.favorite_border, color: item.isFavorite ? Colors.red : Colors.white, size: 20),
                            onPressed: () => db.toggleFavorite(item.file.path, !item.isFavorite),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        _buildBottomFilterBar(),
      ],
    );
  }

  Widget _buildBottomFilterBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Všetky'), icon: Icon(Icons.photo_library)),
            ButtonSegment(value: true, label: Text('Obľúbené'), icon: Icon(Icons.favorite)),
          ],
          selected: {_showOnlyFavorites},
          onSelectionChanged: (value) => setState(() => _showOnlyFavorites = value.first),
        ),
      ),
    );
  }
}

class _PhotoItem {
  final File file;
  final bool isFavorite;
  final bool isUploaded;
  final String? ownerName;
  final double? latitude;
  final double? longitude;

  _PhotoItem({
    required this.file, required this.isFavorite, required this.isUploaded,
    this.ownerName, this.latitude, this.longitude,
  });
}
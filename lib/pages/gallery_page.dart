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
  final Set<String> _selectedPaths = {};
  bool _selectionMode = false;
  bool _isSyncing = false;

  String? _currentUserEmail;
  String? _currentUserRole;
  String? _currentCompanyId;

  // Cache pre dešifrované obrázky – zabraňuje blikaniu pri rebuildoch
  final Map<String, Uint8List> _cache = {};
  // Sledovanie prebiehajúcich dešifrovaní
  final Set<String> _loading = {};

  List<_PhotoItem> _currentItems = [];
  StreamSubscription<List<_PhotoItem>>? _streamSub;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  void initState() {
    super.initState();
    _loadUserIdentity();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<AppDatabase>(context);
  }

  Future<void> _loadUserIdentity() async {
    // ZJEDNOTENIE: Používame 'company_code' pre konzistenciu s AuthService a SyncService
    final email = await _storage.read(key: 'user_email');
    final role = await _storage.read(key: 'user_role');
    final company = await _storage.read(key: 'company_code');

    if (mounted) {
      debugPrint("📸 Gallery Identity: Email: $email, Rola: $role, Firma (ID): $company");
      setState(() {
        _currentUserEmail = email;
        _currentUserRole = role;
        _currentCompanyId = company;
      });
      _subscribeToPhotos();
    }
  }

  void _subscribeToPhotos() {
    _streamSub?.cancel();

    // Ak nemáme dáta o firme alebo používateľovi, čakáme na initState
    if (_currentUserEmail == null || _currentCompanyId == null) {
      debugPrint("⚠️ Gallery: Čakám na načítanie identity...");
      return;
    }

    // Stream podľa roly: Admin vidí celú firmu, Technik len svoje nahlásené veci
    // Drift databáza automaticky vyvolá event, keď SyncService pridá novú fotku do SQLite
    final Stream<List<Photo>> photoStream = (_currentUserRole == 'admin')
        ? db.watchCompanyPhotos(_currentCompanyId!)
        : db.watchUserPhotos(_currentUserEmail!);

    final itemStream = photoStream.asyncMap((rows) async {
      final List<_PhotoItem> items = [];
      for (final row in rows) {
        final file = File(row.filePath);
        // Pri Live Sync kontrolujeme, či už súbor fyzicky existuje na disku
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

    _streamSub = itemStream.listen((items) {
      if (!mounted) return;

      // Spustíme dešifrovanie pre nové súbory, ktoré ešte nie sú v cache
      for (final item in items) {
        final path = item.file.path;
        if (!_cache.containsKey(path) && !_loading.contains(path)) {
          _loading.add(path);
          _decryptAndCache(item.file);
        }
      }

      setState(() {
        _currentItems = items;
      });
    });
  }

  Future<void> _decryptAndCache(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decrypted = await CryptoService.decryptBytes(bytes);
      if (mounted) {
        setState(() {
          _cache[file.path] = decrypted;
          _loading.remove(file.path);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading.remove(file.path));
      }
      debugPrint('❌ Chyba dešifrovania: $e');
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
        if (_selectedPaths.isEmpty) _selectionMode = false;
      } else {
        _selectedPaths.add(path);
        _selectionMode = true;
      }
    });
  }

  void _syncSelected() async {
    setState(() => _isSyncing = true);
    final syncService = SyncService(db);
    int successCount = 0;

    for (final path in _selectedPaths) {
      // syncMedia nahrá súbor a aktualizuje SQLite príznak 'uploaded'
      // Drift stream v _subscribeToPhotos to zachytí a ikona sa sama zmení
      final ok = await syncService.syncMedia(File(path), 'image');
      if (ok) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Úspešne spracovaných $successCount fotiek.')),
      );
      setState(() {
        _isSyncing = false;
        _selectedPaths.clear();
        _selectionMode = false;
      });
    }
  }

  void _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vymazať výber?'),
        content: Text('Naozaj chcete vymazať ${_selectedPaths.length} položiek?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zrušiť')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vymazať', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final path in _selectedPaths) {
        final file = File(path);
        if (await file.exists()) await file.delete();
        _cache.remove(path);
        await db.deletePhoto(path);
      }
      setState(() {
        _selectedPaths.clear();
        _selectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _selectionMode ? _buildSelectionBar() : const SizedBox.shrink(),
        ),

        Expanded(
          child: _currentItems.isEmpty
              ? const Center(child: Text('Trezor fotiek je prázdny'))
              : GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _currentItems.length,
            itemBuilder: (context, index) {
              final item = _currentItems[index];
              final path = item.file.path;
              final isSelected = _selectedPaths.contains(path);
              final imageBytes = _cache[path];

              return GestureDetector(
                onLongPress: () => _toggleSelection(path),
                onTap: () {
                  if (_selectionMode) {
                    _toggleSelection(path);
                  } else if (imageBytes != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenImagePage(
                          imageBytes: imageBytes,
                          photoName: item.ownerName ?? 'Neznámy',
                          latitude: item.latitude,
                          longitude: item.longitude,
                        ),
                      ),
                    );
                  }
                },
                child: _PhotoTile(
                  imageBytes: imageBytes,
                  isSelected: isSelected,
                  isFavorite: item.isFavorite,
                  isUploaded: item.isUploaded,
                  selectionMode: _selectionMode,
                  onFavoriteToggle: () => db.toggleFavorite(path, !item.isFavorite),
                ),
              );
            },
          ),
        ),

        _buildBottomFilterBar(),
      ],
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('${_selectedPaths.length} vybrané', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_isSyncing)
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.blue), onPressed: _syncSelected),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _isSyncing ? null : _deleteSelected),
          IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _selectedPaths.clear(); _selectionMode = false; })),
        ],
      ),
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
          onSelectionChanged: (value) {
            setState(() => _showOnlyFavorites = value.first);
            _subscribeToPhotos();
          },
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isSelected;
  final bool isFavorite;
  final bool isUploaded;
  final bool selectionMode;
  final VoidCallback onFavoriteToggle;

  const _PhotoTile({
    required this.imageBytes,
    required this.isSelected,
    required this.isFavorite,
    required this.isUploaded,
    required this.selectionMode,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 3),
        boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)] : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageBytes != null
                ? Image.memory(imageBytes!, fit: BoxFit.cover, gaplessPlayback: true)
                : Container(
                color: Colors.black12,
                child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            ),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.withOpacity(0.50), Colors.blue.withOpacity(0.25)],
                  ),
                ),
                child: const Center(child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 38)),
              ),
            ),

            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
                child: Icon(
                  isUploaded ? Icons.cloud_done : Icons.cloud_off,
                  color: isUploaded ? Colors.greenAccent : Colors.white70,
                  size: 14,
                ),
              ),
            ),

            if (!selectionMode)
              Positioned(
                bottom: -4,
                right: -4,
                child: IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.white, size: 18),
                  onPressed: onFavoriteToggle,
                ),
              ),
          ],
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
    required this.file,
    required this.isFavorite,
    required this.isUploaded,
    this.ownerName,
    this.latitude,
    this.longitude,
  });
}
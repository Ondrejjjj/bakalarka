import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../storage/image_storage.dart';
import '../security/crypto_service.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<AppDatabase>(context);
  }

  Stream<List<_PhotoItem>> _watchPhotos() {
    return db.select(db.photos).watch().asyncMap((rows) async {
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

  void _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vymazať výber?'),
        content: Text('Naozaj chcete vymazať ${_selectedFiles.length} položiek z trezoru?'),
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
    // TU JE ZMENA: Namiesto Scaffold vraciame Column,
    // pretože Scaffold je už v MediaVaultPage
    return Column(
      children: [
        // Ak sme v režime výberu, ukážeme malú lištu s akcia pod prepínačom
        if (_selectionMode)
          Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${_selectedFiles.length} vybrané',
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelected,
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Chyba načítania: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Trezor fotiek je prázdny'),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
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

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullscreenImagePage(
                              imageBytes: bytes,
                              photoName: item.ownerName,
                              latitude: item.latitude,
                              longitude: item.longitude,
                            ),
                          ),
                        );
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FutureBuilder<Uint8List>(
                          future: _decryptForDisplay(item.file),
                          builder: (context, thumbSnapshot) {
                            if (thumbSnapshot.connectionState == ConnectionState.waiting) {
                              return Container(color: Colors.black12);
                            }
                            if (thumbSnapshot.hasError || !thumbSnapshot.hasData) {
                              return Container(color: Colors.grey, child: const Icon(Icons.error));
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(thumbSnapshot.data!, fit: BoxFit.cover),
                            );
                          },
                        ),
                        if (isSelected)
                          Container(
                            color: Colors.black54,
                            child: const Icon(Icons.check_circle, color: Colors.blue, size: 32),
                          ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Icon(
                            item.isUploaded ? Icons.cloud_done : Icons.cloud_off,
                            color: item.isUploaded ? Colors.greenAccent : Colors.white70,
                            size: 14,
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: IconButton(
                            icon: Icon(
                              item.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: item.isFavorite ? Colors.red : Colors.white,
                              size: 20,
                            ),
                            onPressed: () async {
                              await db.toggleFavorite(item.file.path, !item.isFavorite);
                            },
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
        // Filter zostáva na spodku tejto pod-stránky
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
          onSelectionChanged: (value) {
            setState(() {
              _showOnlyFavorites = value.first;
            });
          },
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
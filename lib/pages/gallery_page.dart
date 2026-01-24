import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  late Future<List<File>> _imagesFuture;
  final Set<File> _selectedFiles = {}; // vybrané fotky na mazanie
  bool _selectionMode = false;

  final AppDatabase db = AppDatabase();

  @override
  void initState() {
    super.initState();
    _imagesFuture = ImageStorage.getAllEncryptedFiles();
  }

  Future<Uint8List> _decryptFile(File file) async {
    final bytes = await file.readAsBytes();
    return CryptoService.decryptBytes(bytes);
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
        title: const Text('Vymazať fotky?'),
        content: Text('Naozaj chcete vymazať ${_selectedFiles.length} fotky?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vymazať'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (var file in _selectedFiles) {
        if (await file.exists()) {
          await file.delete();
        }
      }
      setState(() {
        _selectedFiles.clear();
        _selectionMode = false;
        _imagesFuture = ImageStorage.getAllEncryptedFiles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode
            ? '${_selectedFiles.length} vybrané'
            : 'Galéria'),
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: FutureBuilder<List<File>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final files = snapshot.data ?? [];
          if (files.isEmpty) {
            return const Center(child: Text('Zatiaľ žiadne fotky'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final isSelected = _selectedFiles.contains(file);

              return FutureBuilder<bool>(
                future: db.isPhotoUploaded(file.path), // tu kontrolujeme stav uploadu
                builder: (context, uploadedSnapshot) {
                  final isUploaded = uploadedSnapshot.data ?? false;

                  return GestureDetector(
                    onLongPress: () => _toggleSelection(file),
                    onTap: () async {
                      if (_selectionMode) {
                        _toggleSelection(file);
                      } else {
                        final bytes = await _decryptFile(file);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullscreenImagePage(imageBytes: bytes),
                          ),
                        );
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FutureBuilder<Uint8List>(
                          future: _decryptFile(file),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                        // overlay pre výber
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.check_circle,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                        // malá ikona pre upload stav
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            isUploaded ? Icons.cloud_done : Icons.cloud_upload,
                            color: isUploaded ? Colors.green : Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


class _EncryptedImageTile extends StatelessWidget {
  final File file;
  final VoidCallback? onDeleted; // voliteľný callback na refresh galérie

  const _EncryptedImageTile({
    required this.file,
    this.onDeleted,
  });

  Future<Uint8List> _loadImage() async {
    final encrypted = await file.readAsBytes();
    return CryptoService.decryptBytes(encrypted);
  }

  Future<void> _deleteImage(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vymazať fotku?'),
        content: const Text('Naozaj chcete túto fotku vymazať?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vymazať'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await file.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotka vymazaná')),
      );
      if (onDeleted != null) onDeleted!();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba pri vymazaní: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: InkWell(
          onTap: () async {
            final bytes = await _loadImage();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullscreenImagePage(imageBytes: bytes),
              ),
            );
          },
          onLongPress: () => _deleteImage(context), // Dlhé stlačenie = vymazať
          child: FutureBuilder<Uint8List>(
            future: _loadImage(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }
}

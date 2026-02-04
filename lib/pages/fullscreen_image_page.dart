import 'dart:typed_data';
import 'package:bakalarka/widgets/photo_map_preview.dart';
import 'package:flutter/material.dart';

class FullscreenImagePage extends StatelessWidget {
  final Uint8List imageBytes;
  final String? photoName;
  final double? latitude;
  final double? longitude;

  const FullscreenImagePage({
    super.key,
    required this.imageBytes,
    this.photoName,
    this.latitude,
    this.longitude,
  });

  // V súbore fullscreen_image_page.dart uprav metódu _showDetailsSheet:

  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Aby sa zmestila aj mapa
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(
                photoName ?? 'Neznámy majiteľ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (latitude != null && longitude != null) ...[
                // Tu vložíme náš nový oddelený komponent mapy
                PhotoMapPreview(latitude: latitude!, longitude: longitude!),
                const SizedBox(height: 12),
                Text(
                  'Poloha: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ] else
                const Text('K tejto fotke nie sú dostupné GPS údaje.', style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Swipe hore
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            _showDetailsSheet(context);
          }
        },
        child: Center(
          child: InteractiveViewer(
            child: Image.memory(imageBytes),
          ),
        ),
      ),
    );
  }
}

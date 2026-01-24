import 'dart:typed_data';
import 'package:flutter/material.dart';

class FullscreenImagePage extends StatelessWidget {
  final Uint8List imageBytes;

  const FullscreenImagePage({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}

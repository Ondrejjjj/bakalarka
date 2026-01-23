import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- pridané pre vibráciu
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isFlashOn = false;
  bool _isReady = false;

  // Zoom
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  // Pre flash animáciu
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    _minZoom = await _controller!.getMinZoomLevel();
    _maxZoom = await _controller!.getMaxZoomLevel();
    _currentZoom = _minZoom;

    setState(() {
      _isReady = true;
    });
  }

  Future<void> _takePhoto() async {
    if (!_controller!.value.isInitialized) return;

    // Vibrácia pri fotení
    HapticFeedback.mediumImpact();

    // Flash animácia
    setState(() => _showFlash = true);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _showFlash = false);

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile photo = await _controller!.takePicture();
    await photo.saveTo(path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fotka uložená: $path')),
    );
  }

  void _toggleFlash() async {
    _isFlashOn = !_isFlashOn;

    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          /// FLASH ANIMÁCIA
          if (_showFlash)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.4),
              ),
            ),

          /// TOP BAR
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
          ),

          /// ZOOM SLIDER
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: Material(
              color: Colors.transparent,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 18),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white38,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  min: _minZoom,
                  max: _maxZoom,
                  value: _currentZoom.clamp(_minZoom, _maxZoom),
                  onChanged: (val) async {
                    _currentZoom = val;
                    await _controller!.setZoomLevel(val);
                    setState(() {}); // refresh slider a kamera
                  },
                ),
              ),
            ),
          ),

          /// BOTTOM CAPTURE BUTTON
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

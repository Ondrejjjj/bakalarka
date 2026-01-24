import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bakalarka/storage/image_storage.dart';
import 'package:bakalarka/security/crypto_service.dart';

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

  // Video
  bool _isVideoMode = false;
  bool _isRecording = false;
  Duration _videoDuration = Duration.zero;
  Timer? _videoTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Žiadna kamera dostupná')),
        );
        return;
      }

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();

      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = _minZoom;

      setState(() {
        _isReady = true;
      });
    } catch (e) {
      // ak sa kamera nespustí, zobrazí chybu namiesto zaseknutia
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba pri inicializácii kamery: $e')),
      );
    }
  }


  Future<void> _takePhoto() async {
    if (!_controller!.value.isInitialized || _isRecording) return;

    final XFile photo = await _controller!.takePicture();
    final bytes = await File(photo.path).readAsBytes();

    final encryptedBytes =
    await CryptoService.encryptBytes(bytes);

    final imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final file = await ImageStorage.createEncryptedFile(imageId);

    await file.writeAsBytes(encryptedBytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔐 Fotka šifrovane uložená')),
    );
  }



  Future<void> _startVideo() async {
    if (!_controller!.value.isInitialized || _isRecording) return;

    await _controller!.startVideoRecording();
    _isRecording = true;
    _videoDuration = Duration.zero;

    _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _videoDuration += const Duration(seconds: 1);
      });
    });

    setState(() {});
  }



  Future<void> _stopVideo() async {
    if (!_isRecording) return;

    final XFile video = await _controller!.stopVideoRecording();
    _isRecording = false;
    _videoTimer?.cancel();

    final bytes = await File(video.path).readAsBytes();
    final videoId = DateTime.now().millisecondsSinceEpoch.toString();

    final dir = await getApplicationDocumentsDirectory();
    final secureVideoDir = Directory('${dir.path}/secure_videos');

    if (!await secureVideoDir.exists()) {
      await secureVideoDir.create(recursive: true);
    }

    final secureFile = File('${secureVideoDir.path}/$videoId.enc');
    await secureFile.writeAsBytes(bytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video bezpečne uložené')),
    );

    setState(() {});
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
    _videoTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

          /// VIDEO DURATION
          if (_isRecording)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDuration(_videoDuration),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          /// ZOOM SLIDER
          Positioned(
            left: 20,
            right: 20,
            bottom: 160,
            child: Material(
              color: Colors.transparent,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
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
                    setState(() {});
                  },
                ),
              ),
            ),
          ),

          /// MODE TOOLBAR (Foto/Video)
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModeButton(
                  label: 'Foto',
                  isActive: !_isVideoMode,
                  onTap: () {
                    setState(() {
                      _isVideoMode = false;
                    });
                  },
                ),
                const SizedBox(width: 20),
                _ModeButton(
                  label: 'Video',
                  isActive: _isVideoMode,
                  onTap: () {
                    setState(() {
                      _isVideoMode = true;
                    });
                  },
                ),
              ],
            ),
          ),

          /// BOTTOM CAPTURE BUTTON
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (_isVideoMode) {
                    if (_isRecording) {
                      await _stopVideo();
                    } else {
                      await _startVideo();
                    }
                  } else {
                    await _takePhoto();
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: _isRecording
                      ? const Icon(Icons.stop, color: Colors.red, size: 30)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

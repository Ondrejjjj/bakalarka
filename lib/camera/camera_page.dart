import 'dart:async';
import 'dart:io';
import 'dart:ui'; // Pre BackdropFilter ak by sme chceli, ale gradient je performantnejsi
import 'package:bakalarka/database.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bakalarka/storage/image_storage.dart';
import 'package:bakalarka/security/crypto_service.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:native_exif/native_exif.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isFlashOn = false;
  bool _isReady = false;

  // Zoom
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  // Video & Modes
  bool _isVideoMode = false; // false = Foto, true = Video
  bool _isRecording = false;
  Duration _videoDuration = Duration.zero;
  Timer? _videoTimer;

  // UI Animation
  bool _isCapturing = false; // Pre efekt "bliknutia" obrazovky pri fotení

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // Rieši situáciu, keď aplikáciu minimalizuješ a vrátiš sa späť
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Vyberieme zadnú kameru ako default
      final camera = _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.jpeg : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();

      // Zámok orientácie na portrét pre jednoduchosť UI
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = _minZoom;

      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) return;

    // Vizuálny efekt odfotenia (bliknutie)
    setState(() => _isCapturing = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isCapturing = false);
    });

    try {
      final XFile photo = await _controller!.takePicture();

      // Odstránenie EXIF (zachované z tvojho kódu)
      await _stripExif(photo.path);

      final bytes = await File(photo.path).readAsBytes();
      final encryptedBytes = await CryptoService.encryptBytes(bytes);

      final imageId = DateTime.now().millisecondsSinceEpoch.toString();
      final file = await ImageStorage.createEncryptedFile(imageId);

      await file.writeAsBytes(encryptedBytes, flush: true);

      // Získanie polohy
      double? latitude;
      double? longitude;
      try {
        Location location = Location();
        if (await location.serviceEnabled() || await location.requestService()) {
          if (await location.hasPermission() == PermissionStatus.granted ||
              await location.requestPermission() == PermissionStatus.granted) {
            final locData = await location.getLocation();
            latitude = locData.latitude;
            longitude = locData.longitude;
          }
        }
      } catch (e) {
        debugPrint('Location error: $e');
      }

      if (!mounted) return;

      // Zápis do DB
      final db = context.read<AppDatabase>();
      await db.insertPhoto(
        ownerName: "user",
        filePath: file.path,
        latitude: latitude,
        longitude: longitude,
        uploaded: false,
        deviceId: '90',
      );

      // Vymazanie dočasného súboru
      final tempFile = File(photo.path);
      if (await tempFile.exists()) await tempFile.delete();

    } catch (e) {
      debugPrint("Photo capture error: $e");
    }
  }

  Future<void> _startVideo() async {
    if (!_controller!.value.isInitialized || _isRecording) return;

    await _controller!.startVideoRecording();
    setState(() {
      _isRecording = true;
      _videoDuration = Duration.zero;
    });

    _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _videoDuration += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _stopVideo() async {
    if (!_isRecording) return;

    try {
      final XFile video = await _controller!.stopVideoRecording();
      _videoTimer?.cancel();
      setState(() => _isRecording = false);

      final bytes = await File(video.path).readAsBytes();
      final encryptedBytes = await CryptoService.encryptBytes(bytes);

      final videoId = DateTime.now().millisecondsSinceEpoch.toString();
      final file = await ImageStorage.createEncryptedFile(videoId); // Ukladá ako .enc

      await file.writeAsBytes(encryptedBytes, flush: true);

      if (!mounted) return;

      final db = context.read<AppDatabase>();
      await db.insertPhoto( // Pozor: Tu ukladáš video do tabuľky pre fotky, ak nemáš Video tabuľku
        filePath: file.path,
        deviceId: '90',
        ownerName: "user",
        uploaded: false,
      );

      // Vymazanie dočasného súboru
      final tempFile = File(video.path);
      if (await tempFile.exists()) await tempFile.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎥 Video zašifrované a uložené')),
      );
    } catch (e) {
      debugPrint("Video stop error: $e");
    }
  }

  Future<void> _stripExif(String path) async {
    try {
      final exif = await Exif.fromPath(path);
      await exif.writeAttributes({});
      await exif.close();
    } catch (e) {
      debugPrint("EXIF error: $e");
    }
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    setState(() => _isFlashOn = !_isFlashOn);
    try {
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Získame rozmery pre správne zobrazenie kamery
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 1. CAMERA PREVIEW
          Center(
            child: CameraPreview(_controller!),
          ),

          /// 2. Flash Overlay Effect (pri odfotení)
          if (_isCapturing)
            Container(color: Colors.black.withOpacity(0.5)),

          /// 3. HORNÁ LIŠTA (Ovládanie blesku a návrat)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tlačidlo späť
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Indikátor nahrávania
                  if (_isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDuration(_videoDuration),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // Blesk
                  IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: _isFlashOn ? Colors.yellow : Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          /// 4. SPODNÝ OVLÁDACÍ PANEL
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.4, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // --- ZOOM SLIDER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        const Text('1x', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              trackHeight: 2,
                            ),
                            child: Slider(
                              value: _currentZoom,
                              min: _minZoom,
                              max: _maxZoom,
                              onChanged: (val) async {
                                setState(() => _currentZoom = val);
                                await _controller!.setZoomLevel(val);
                              },
                            ),
                          ),
                        ),
                        Text('${_maxZoom.toStringAsFixed(0)}x', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- PREPÍNAČ REŽIMOV (TEXTOVÝ) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeText('FOTO', !_isVideoMode),
                      const SizedBox(width: 24),
                      _buildModeText('VIDEO', _isVideoMode),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- SPÚŠŤ ---
                  GestureDetector(
                    onTap: () {
                      if (_isVideoMode) {
                        if (_isRecording) {
                          _stopVideo();
                        } else {
                          _startVideo();
                        }
                      } else {
                        _takePhoto();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: _isVideoMode
                              ? (_isRecording ? 30 : 60) // Video: Červené
                              : 68,                      // Foto: Biele
                          width: _isVideoMode
                              ? (_isRecording ? 30 : 60)
                              : 68,
                          decoration: BoxDecoration(
                            color: _isVideoMode ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(
                              _isVideoMode && _isRecording ? 4 : 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeText(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (_isRecording) return; // Nemeniť počas nahrávania
        setState(() {
          _isVideoMode = (text == 'VIDEO');
        });
      },
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: isActive ? Colors.yellowAccent : Colors.white54,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          shadows: isActive
              ? [const BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))]
              : null,
        ),
        child: Text(text),
      ),
    );
  }
}
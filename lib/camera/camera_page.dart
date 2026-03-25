import 'dart:async';
import 'dart:io';
import 'dart:ui';
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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' as drift; // Potrebné pre drift.Value

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

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Lokálna cache pre údaje o používateľovi
  String _cachedEmail = 'unknown_user';
  String _cachedCompany = 'unknown_company';
  String _cachedOwnerName = 'Technik';

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  bool _isVideoMode = false;
  bool _isRecording = false;
  Duration _videoDuration = Duration.zero;
  Timer? _videoTimer;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOfflineCredentials();
    _initCamera();
  }

  // ZJEDNOTENÉ: Načítavame 'company_id', aby to sedelo s Galériou
  Future<void> _loadOfflineCredentials() async {
    try {
      final email = await _storage.read(key: 'user_email');
      final company = await _storage.read(key: 'company_id'); // Opravený kľúč
      final name = await _storage.read(key: 'user_name');

      if (mounted) {
        setState(() {
          _cachedEmail = email ?? 'unknown_user';
          _cachedCompany = company ?? 'unknown_company';
          _cachedOwnerName = name ?? 'Technik';
        });
      }
    } catch (e) {
      debugPrint("❌ Chyba načítania offline údajov: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

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
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = _minZoom;

      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      debugPrint("❌ Camera init error: $e");
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) return;

    setState(() => _isCapturing = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isCapturing = false);
    });

    try {
      final XFile photo = await _controller!.takePicture();
      await _stripExif(photo.path);

      // Šifrovanie
      final bytes = await File(photo.path).readAsBytes();
      final encryptedBytes = await CryptoService.encryptBytes(bytes);

      final imageId = "img_${DateTime.now().millisecondsSinceEpoch}";
      final file = await ImageStorage.createEncryptedFile(imageId);
      await file.writeAsBytes(encryptedBytes, flush: true);

      // Poloha
      double? lat;
      double? lon;
      try {
        Location location = Location();
        final locData = await location.getLocation().timeout(const Duration(seconds: 3));
        lat = locData.latitude;
        lon = locData.longitude;
      } catch (_) {}

      if (!mounted) return;
      final db = context.read<AppDatabase>();

      // ZÁPIS DO DB (Stĺpec companyCode v DB dostane hodnotu _cachedCompany, čo je naše company_id)
      await db.insertPhoto(
        filePath: file.path,
        deviceId: '90',
        userEmail: _cachedEmail,
        companyCode: _cachedCompany,
        ownerName: _cachedOwnerName,
        uploaded: false,
        latitude: lat,
        longitude: lon,
      );

      await File(photo.path).delete();
      debugPrint("✅ Foto uložené: ${file.path}");
    } catch (e) {
      debugPrint("❌ Photo capture error: $e");
    }
  }

  Future<void> _startVideo() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) return;
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _videoDuration = Duration.zero;
      });
      _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() => _videoDuration += const Duration(seconds: 1));
      });
    } catch (e) {
      debugPrint("❌ Video start error: $e");
    }
  }

  Future<void> _stopVideo() async {
    if (!_isRecording) return;
    try {
      final XFile video = await _controller!.stopVideoRecording();
      _videoTimer?.cancel();
      final int duration = _videoDuration.inSeconds;

      setState(() => _isRecording = false);

      final bytes = await File(video.path).readAsBytes();
      final encryptedBytes = await CryptoService.encryptBytes(bytes);

      final videoId = "vid_${DateTime.now().millisecondsSinceEpoch}";
      final file = await ImageStorage.createEncryptedFile(videoId);
      await file.writeAsBytes(encryptedBytes, flush: true);

      if (!mounted) return;
      final db = context.read<AppDatabase>();

      // ZÁPIS VIDEA DO DB
      await db.insertVideo(
        filePath: file.path,
        deviceId: '90',
        userEmail: _cachedEmail,
        companyCode: _cachedCompany,
        ownerName: _cachedOwnerName,
        uploaded: false,
        duration: duration,
      );

      await File(video.path).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎥 Video zašifrované a uložené')),
      );
    } catch (e) {
      debugPrint("❌ Video stop error: $e");
    }
  }

  Future<void> _stripExif(String path) async {
    try {
      final exif = await Exif.fromPath(path);
      await exif.writeAttributes({});
      await exif.close();
    } catch (_) {}
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: CameraPreview(_controller!)),
          if (_isCapturing) Container(color: Colors.black.withOpacity(0.5)),

          // Horná lišta
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent])),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)),
                  if (_isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                      child: Text(_formatDuration(_videoDuration), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  IconButton(icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: _isFlashOn ? Colors.yellow : Colors.white, size: 28), onPressed: _toggleFlash),
                ],
              ),
            ),
          ),

          // Spodný panel (Zoom + Módy + Spúšť)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black, Colors.transparent], stops: [0.4, 1.0])),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        const Text('1x', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Expanded(child: Slider(
                          value: _currentZoom, min: _minZoom, max: _maxZoom,
                          activeColor: Colors.white, inactiveColor: Colors.white24,
                          onChanged: (val) { setState(() => _currentZoom = val); _controller!.setZoomLevel(val); },
                        )),
                        Text('${_maxZoom.toStringAsFixed(0)}x', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeText('FOTO', !_isVideoMode),
                      const SizedBox(width: 24),
                      _buildModeText('VIDEO', _isVideoMode),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _isVideoMode ? (_isRecording ? _stopVideo() : _startVideo()) : _takePhoto(),
                    child: Container(
                      height: 80, width: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                      child: Center(child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _isRecording ? 30 : 65, width: _isRecording ? 30 : 65,
                        decoration: BoxDecoration(color: _isVideoMode ? Colors.red : Colors.white, borderRadius: BorderRadius.circular(_isRecording ? 4 : 50)),
                      )),
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
      onTap: () { if (!_isRecording) setState(() => _isVideoMode = (text == 'VIDEO')); },
      child: Text(text, style: TextStyle(color: isActive ? Colors.yellowAccent : Colors.white54, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }
}
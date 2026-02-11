// widgets/sync_button.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncButton extends StatefulWidget {
  final Set<File> selectedFiles;
  final String mediaType; // 'image', 'video', 'audio'
  final SyncService syncService;
  final VoidCallback onSyncComplete;

  const SyncButton({
    super.key,
    required this.selectedFiles,
    required this.mediaType,
    required this.syncService,
    required this.onSyncComplete,
  });

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  bool _isUploading = false;

  void _handleSync() async {
    setState(() => _isUploading = true);

    try {
      for (var file in widget.selectedFiles) {
        await widget.syncService.syncMedia(file, widget.mediaType);
      }
      widget.onSyncComplete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synchronizácia ${widget.selectedFiles.length} položiek úspešná')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chyba pri synchronizácii')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedFiles.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: _isUploading ? null : _handleSync,
      backgroundColor: Colors.blue,
      icon: _isUploading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.cloud_upload),
      label: Text(_isUploading ? 'Odosielam...' : 'Odoslať do cloudu'),
    );
  }
}
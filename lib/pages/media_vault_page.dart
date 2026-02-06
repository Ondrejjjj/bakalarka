import 'package:flutter/material.dart';
import 'gallery_page.dart';
import 'audio_gallery_page.dart';

class MediaVaultPage extends StatefulWidget {
  const MediaVaultPage({super.key});

  @override
  State<MediaVaultPage> createState() => _MediaVaultPageState();
}

class _MediaVaultPageState extends State<MediaVaultPage> {
  // 0 = Foto, 1 = Video, 2 = Audio
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar s jemným tieňom a Material 3 dizajnom
      appBar: AppBar(
        title: const Text(
          'Zabezpečený Trezor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // MODERNÝ PREPÍNAČ (Material 3 SegmentedButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                style: SegmentedButton.styleFrom(
                  // Farba pozadia pre vybraný segment
                  selectedBackgroundColor: theme.colorScheme.primaryContainer,
                  selectedForegroundColor: theme.colorScheme.onPrimaryContainer,
                ),
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.image_outlined),
                    label: Text('Foto'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.videocam_outlined),
                    label: Text('Video'),
                  ),
                  ButtonSegment(
                    value: 2,
                    icon: Icon(Icons.mic_none_rounded),
                    label: Text('Audio'),
                  ),
                ],
                selected: {_selectedIndex},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedIndex = newSelection.first;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),

          // OBSAH GALÉRIE S ANIMÁCIOU PRECHODU
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildGalleryContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Pomocná funkcia, ktorá vráti správnu pod-stránku
  Widget _buildGalleryContent() {
    switch (_selectedIndex) {
      case 0:
      // Tu sa vráti tvoja upravená GalleryPage (bez Scaffold-u)
        return const GalleryPage(key: ValueKey(0));
      case 1:
        return _buildPlaceholder('Galéria videí sa pripravuje', Icons.videocam);
      case 2:
        return const AudioGalleryPage(key: ValueKey(2));
      default:
        return const SizedBox.shrink();
    }
  }

  /// Placeholder pre sekcie, ktoré ešte nemáš hotové (napr. Videá)
  Widget _buildPlaceholder(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
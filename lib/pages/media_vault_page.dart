import 'package:bakalarka/pages/video_gallery_page.dart';
import 'package:flutter/material.dart';
import 'gallery_page.dart';
import 'audio_gallery_page.dart';

class MediaVaultPage extends StatefulWidget {
  const MediaVaultPage({super.key});

  @override
  State<MediaVaultPage> createState() => _MediaVaultPageState();
}

class _MediaVaultPageState extends State<MediaVaultPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // 1. Pozadie necháme na celú obrazovku, aby gradient prechádzal aj pod stavovú lištu
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        // 2. TUTO JE ZMENA: SafeArea obalí vnútro, aby text nešiel pod hodiny/kameru
        child: SafeArea(
          bottom: false, // Spodok necháme "pretiecť", aby galéria išla až po okraj
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  // Trochu som zmenšil výšku, keďže SafeArea už pridala priestor
                  expandedHeight: 140.0,
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    // Odstránil som SizedBox(height: 60), SafeArea to vyrieši za nás
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Môj Trezor',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: SegmentedButton<int>(
                              style: SegmentedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                selectedBackgroundColor: colorScheme.primary,
                                selectedForegroundColor: colorScheme.onPrimary,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              segments: const [
                                ButtonSegment(value: 0, icon: Icon(Icons.image_rounded), label: Text('Foto')),
                                ButtonSegment(value: 1, icon: Icon(Icons.videocam_rounded), label: Text('Video')),
                                ButtonSegment(value: 2, icon: Icon(Icons.mic_rounded), label: Text('Audio')),
                              ],
                              selected: {_selectedIndex},
                              onSelectionChanged: (newSelection) {
                                setState(() => _selectedIndex = newSelection.first);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: _buildGalleryContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryContent() {
    switch (_selectedIndex) {
      case 0: return GalleryPage(key: const ValueKey(0));
      case 1: return VideoGalleryPage(key: const ValueKey(1));
      case 2: return AudioGalleryPage(key: const ValueKey(2));
      default: return const SizedBox.shrink();
    }
  }
}
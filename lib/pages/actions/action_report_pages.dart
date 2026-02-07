import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bakalarka/database.dart'; // Tvoja Drift databáza
import 'dart:io';

class ActionReportPage extends StatefulWidget {
  final String title;
  final IconData icon;

  const ActionReportPage({super.key, required this.title, required this.icon});

  @override
  State<ActionReportPage> createState() => _ActionReportPageState();
}

class _ActionReportPageState extends State<ActionReportPage> {
  // Tu budeme ukladať cesty k vybraným súborom
  final Set<String> _selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.save_rounded),
        label: const Text("Uložiť report"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(colorScheme, theme),
            const SizedBox(height: 24),

            _buildSectionTitle(context, "Základné údaje"),
            const SizedBox(height: 12),
            TextFormField(decoration: _inputDecoration("Názov / Číslo revízie", Icons.edit)),
            const SizedBox(height: 16),
            TextFormField(maxLines: 3, decoration: _inputDecoration("Popis stavu", Icons.description_outlined)),

            const SizedBox(height: 24),

            // SEKCIA MÉDIÍ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(context, "Priložené médiá (${_selectedPaths.length})"),
                TextButton.icon(
                  onPressed: () => _showMediaPicker(context),
                  icon: const Icon(Icons.add_link_rounded),
                  label: const Text("Pripojiť z trezoru"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _selectedPaths.isEmpty
                ? _buildEmptyMediaBox(context)
                : _buildSelectedMediaGrid(colorScheme),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- POMOCNÉ WIDGETY PRE HLAVNÚ STRÁNKU ---

  Widget _buildHeaderCard(ColorScheme colorScheme, ThemeData theme) {
    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: colorScheme.secondary, child: Icon(widget.icon, color: colorScheme.onSecondary)),
            const SizedBox(width: 16),
            Expanded(child: Text("Dokumentácia pre: ${widget.title}", style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMediaGrid(ColorScheme colorScheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: _selectedPaths.length,
      itemBuilder: (context, index) {
        final path = _selectedPaths.elementAt(index);
        final isVideo = path.contains('video'); // Jednoduchá detekcia typu pre prototyp

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Center(child: Icon(isVideo ? Icons.videocam : Icons.image, size: 20)),
            ),
            Positioned(
              right: 0, top: 0,
              child: GestureDetector(
                onTap: () => setState(() => _selectedPaths.remove(path)),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  // --- BEZPEČNÝ MEDIA PICKER (MODAL) ---

  void _showMediaPicker(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.image), text: "Fotky"),
                    Tab(icon: Icon(Icons.videocam), text: "Videá"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPickerList(db.watchAllPhotos()),
                      _buildPickerList(db.watchAllVideos()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hotovo"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerList(Stream<List<dynamic>> stream) {
    return StreamBuilder<List<dynamic>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;

        if (items.isEmpty) return const Center(child: Text("Trezor je prázdny"));

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = _selectedPaths.contains(item.filePath);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) _selectedPaths.remove(item.filePath);
                  else _selectedPaths.add(item.filePath);
                });
                (context as Element).markNeedsBuild(); // Vynúti refresh Modalu
              },
              child: Card(
                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item is Photo ? Icons.image : Icons.videocam),
                    const SizedBox(height: 4),
                    Text("#${item.id}", style: const TextStyle(fontSize: 10)),
                    if (isSelected) const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- EXISTUJÚCE POMOCNÉ METÓDY ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary));
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Theme.of(context).colorScheme.surface);
  }

  Widget _buildEmptyMediaBox(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16), color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2)),
      child: Column(children: [Icon(Icons.perm_media_outlined, color: Theme.of(context).colorScheme.outline), const SizedBox(height: 8), Text("Zatiaľ žiadne súbory", style: TextStyle(color: Theme.of(context).colorScheme.outline))]),
    );
  }
}

// Konkrétne implementácie zostávajú rovnaké ako predtým...
class RevisionBeforePage extends StatelessWidget {
  const RevisionBeforePage({super.key});
  @override
  Widget build(BuildContext context) => const ActionReportPage(title: "Revízia pred", icon: Icons.fact_check);
}

class RevisionAfterPage extends StatelessWidget {
  const RevisionAfterPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionReportPage(title: "Revízia po", icon: Icons.fact_check_outlined);
}

class RepairBeforePage extends StatelessWidget {
  const RepairBeforePage({super.key});
  @override
  Widget build(BuildContext context) => const ActionReportPage(title: "Oprava pred", icon: Icons.build);
}

class RepairAfterPage extends StatelessWidget {
  const RepairAfterPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionReportPage(title: "Oprava po", icon: Icons.build_circle);
}
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavenia'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, 'Profil'),
          _card(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Meno používateľa',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle(context, 'Pripojenie'),
          _card(
            child: Column(
              children: [
                _settingsButton(
                  context,
                  title: 'Wi-Fi Nastavenia',
                  icon: Icons.wifi_rounded,
                  onTap: () {
                    AppSettings.openAppSettings(type: AppSettingsType.wifi);
                  },
                ),
                const Divider(),
                _settingsButton(
                  context,
                  title: 'Mobilné dáta',
                  icon: Icons.network_cell_rounded,
                  onTap: () {
                    AppSettings.openAppSettings(type: AppSettingsType.dataRoaming);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle(context, 'Úložisko'),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Úroveň čistenia fotiek: 3'),
                Slider(
                  value: 3,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '3',
                  onChanged: (value) {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
      _sectionTitle(context, 'Vzhľad'),
      _card(
        child: Column(
          children: [
            const Text('Téma aplikácie'),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Systém'),
                  icon: Icon(Icons.settings_suggest),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Svetlá'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Tmavá'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {context.watch<ThemeProvider>().themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                context.read<ThemeProvider>().setThemeMode(newSelection.first);
              },
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _settingsButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }
}

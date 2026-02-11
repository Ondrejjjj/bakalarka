import 'package:bakalarka/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Na kopírovanie do schránky
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart'; // Na zdieľanie kódu
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _auth = AuthService();
  String? _currentCode;
  String? _companyId;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final role = await _auth.getUserRole(user.uid);
      final companyData = await _auth.getCompanyData();

      if (mounted) {
        setState(() {
          _isAdmin = role == 'admin';
          _currentCode = companyData?.get('inviteCode');
          _companyId = companyData?.id;
        });
      }
    }
  }

  void _regenerateCode() async {
    if (_companyId == null) return;

    // Potvrdzovací dialóg
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pregenerovať kód?"),
        content: const Text("Starý kód prestane okamžite fungovať pre nových technikov."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Zrušiť")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Áno, zmeniť")),
        ],
      ),
    ) ?? false;

    if (confirm) {
      String newCode = await _auth.regenerateInviteCode(_companyId!);
      setState(() => _currentCode = newCode);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kód bol zmenený")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nastavenia'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SEKCIU PRE ADMINA (KÓD A ZAMESTNANCI) ---
          if (_isAdmin) ...[
            _sectionTitle(context, 'Firemný prístup (Admin)'),
            _card(
              child: Column(
                children: [
                  const Text("Vstupný kód pre technikov:", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    _currentCode ?? "Načítavam...",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionIcon(Icons.copy, "Kopírovať", () {
                        Clipboard.setData(ClipboardData(text: _currentCode ?? ""));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Skopírované do schránky")));
                      }),
                      _actionIcon(Icons.share, "Zdieľať", () {
                        Share.share("Ahoj, prihlás sa do našej appky Trezor pomocou kódu: $_currentCode");
                      }),
                      _actionIcon(Icons.refresh, "Zmeniť", _regenerateCode),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle(context, 'Moji technici'),
            _card(
              child: _companyId == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                stream: _auth.getCompanyEmployees(_companyId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("Zatiaľ nemáte žiadnych technikov.",
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      var employee = snapshot.data!.docs[index];
                      String email = employee['email'] ?? 'Neznámy email';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(email[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                        ),
                        title: Text(email),
                        subtitle: const Text("Technik"),
                        trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // --- OSTATNÉ NASTAVENIA ---
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
                _settingsButton(context, title: 'Wi-Fi Nastavenia', icon: Icons.wifi_rounded, onTap: () => AppSettings.openAppSettings(type: AppSettingsType.wifi)),
                const Divider(),
                _settingsButton(context, title: 'Mobilné dáta', icon: Icons.network_cell_rounded, onTap: () => AppSettings.openAppSettings(type: AppSettingsType.dataRoaming)),
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
                Slider(value: 3, min: 1, max: 5, divisions: 4, label: '3', onChanged: (v) {}),
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
                    ButtonSegment(value: ThemeMode.system, label: Text('Systém'), icon: Icon(Icons.settings_suggest)),
                    ButtonSegment(value: ThemeMode.light, label: Text('Svetlá'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Tmavá'), icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {context.watch<ThemeProvider>().themeMode},
                  onSelectionChanged: (newSelection) => context.read<ThemeProvider>().setThemeMode(newSelection.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pomocný widget pre malé akčné tlačidlá pod kódom
  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
    );
  }

  Widget _card({required Widget child}) {
    return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(16), child: child)
    );
  }

  Widget _settingsButton(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap
    );
  }
}
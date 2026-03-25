import 'package:bakalarka/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bakalarka/database.dart';
import 'theme.dart';
import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // OPRAVA: AuthService vyžaduje databázu, ktorú získame neskôr
  late AuthService _auth;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _currentCode;
  String? _companyId;
  bool _isAdmin = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializácia AuthService pomocou databázy z Providera
    final database = Provider.of<AppDatabase>(context, listen: false);
    _auth = AuthService(database);

    _loadInitialData();
  }

  // --- LOGIKA NAČÍTANIA DÁT ---
  void _loadInitialData() async {
    final savedRole = await _storage.read(key: 'user_role');
    final savedCompanyId = await _storage.read(key: 'company_id'); // Opravený kľúč na company_id

    if (mounted) {
      setState(() {
        _isAdmin = savedRole == 'admin';
        _companyId = savedCompanyId;
        _isInitialLoading = false;
      });
    }

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final role = await _auth.getUserRole(user.uid);
        final companyData = await _auth.getCompanyData();

        if (mounted) {
          setState(() {
            _isAdmin = role == 'admin';
            _companyId = companyData?.id ?? savedCompanyId;
            _currentCode = companyData?.get('inviteCode');
          });
        }
      } catch (e) {
        debugPrint("Chyba pri aktualizácii dát z cloudu: $e");
      }
    }
  }

  void _regenerateCode() async {
    if (_companyId == null) return;

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pregenerovať kód?"),
        content: const Text("Starý kód prestane okamžite fungovať pre nových technikov."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.of(context).zrusitB)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Áno, zmeniť")),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        String newCode = await _auth.regenerateInviteCode(_companyId!);
        setState(() => _currentCode = newCode);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kód bol zmenený")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chyba pri zmene kódu")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).nastaveniaH), centerTitle: true),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- ADMIN SEKCIU ---
          if (_isAdmin) ...[
            _sectionTitle(context, S.of(context).firemPris),
            _card(
              child: Column(
                children: [
                  Text(S.of(context).kodPreT, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    _currentCode ?? "---",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionIcon(Icons.copy, S.of(context).kopy, () {
                        if (_currentCode != null) {
                          Clipboard.setData(ClipboardData(text: _currentCode!));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Skopírované do schránky")));
                        }
                      }),
                      _actionIcon(Icons.share, S.of(context).zdielatT, () {
                        if (_currentCode != null) {
                          Share.share("Ahoj, prihlás sa do našej appky Trezor pomocou kódu: $_currentCode");
                        }
                      }),
                      _actionIcon(Icons.refresh, S.of(context).zmenitT, _regenerateCode),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle(context, S.of(context).mojiT),
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
          _sectionTitle(context, S.of(context).profilT),
          _card(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Email používateľa',
                hintText: _auth.currentUser?.email ?? '',
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
                enabled: false, // Email by sa nemal meniť len tak
              ),
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle(context, S.of(context).pripojenieT),
          _card(
            child: Column(
              children: [
                _settingsButton(context, title: S.of(context).wifiT, icon: Icons.wifi_rounded, onTap: () => AppSettings.openAppSettings(type: AppSettingsType.wifi)),
                const Divider(),
                _settingsButton(context, title: S.of(context).mobilDH, icon: Icons.network_cell_rounded, onTap: () => AppSettings.openAppSettings(type: AppSettingsType.dataRoaming)),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle(context, S.of(context).vzhladT),
          _card(
            child: Column(
              children: [
                Text(S.of(context).temaT, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(value: ThemeMode.system, label: Text(S.of(context).systemV), icon: const Icon(Icons.settings_suggest)),
                    ButtonSegment(value: ThemeMode.light, label: Text(S.of(context).setloV), icon: const Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemeMode.dark, label: Text(S.of(context).tmavoV), icon: const Icon(Icons.dark_mode)),
                  ],
                  selected: {context.watch<ThemeProvider>().themeMode},
                  onSelectionChanged: (newSelection) => context.read<ThemeProvider>().setThemeMode(newSelection.first),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --- TLAČIDLO ODHLÁSENIA ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                // Odhlásime používateľa
                await _auth.signOut();

                if (mounted) {
                  // VRÁTENIE NA LOGIN: Vymaže celú históriu a vloží Login ako root
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(S.of(context).odhlasV),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Pomocné widgety
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
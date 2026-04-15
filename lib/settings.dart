import 'package:bakalarka/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/pages/login_page.dart';
import 'theme.dart';
import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    final database = Provider.of<AppDatabase>(context, listen: false);
    _auth = AuthService(database);
    _loadInitialData();
  }

  void _loadInitialData() async {
    final savedRole = await _storage.read(key: 'user_role');
    final savedCompanyId = await _storage.read(key: 'company_id');

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
        debugPrint('Chyba pri načítaní dát z cloudu: $e');
      }
    }
  }

  void _regenerateCode() async {
    if (_companyId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).pregeneratKod),
        content: Text(
            S.of(context).staryKodPrestan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).zrusitB),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).anoZmenit),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final newCode = await _auth.regenerateInviteCode(_companyId!);
      setState(() => _currentCode = newCode);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.of(context).kodBylZmeneny)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.of(context).chybaZmenyKodu)));
      }
    }
  }

  // ── Vyhodenie technika z firmy ──────────────────────────────────────────

  Future<void> _removeEmployee(QueryDocumentSnapshot employee) async {
    final email = employee['email'] as String? ?? 'Neznámy';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).odstranitTechnika),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: S.of(context).naozajOdstranit),
              TextSpan(
                  text: email,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  S.of(context).zFirmyText),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).zrusitB),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).odstranit),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      await employee.reference.update({
        'companyCode': FieldValue.delete(),
        'companyId':   FieldValue.delete(),
        'role':        'unassigned',
        'banned':      true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$email bol odstránený z firmy.')),
        );
      }
    } catch (e) {
      debugPrint('Chyba pri odstraňovaní technika: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(S.of(context).chybaTechnika)),
        );
      }
    }
  }


  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).odhlasV),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).zrusitB),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).odhlasV),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm || !mounted) return;

    try {

      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Chyba pri odhlasovaní: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).chybaOdhlasenia)),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).nastaveniaH),
        centerTitle: true,
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Admin sekcia ────────────────────────────────────────
          if (_isAdmin) ...[
            _sectionTitle(S.of(context).firemPris),
            _card(
              child: Column(children: [
                Text(S.of(context).kodPreT,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  _currentCode ?? '---',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionIcon(Icons.copy, S.of(context).kopy, () {
                      if (_currentCode != null) {
                        Clipboard.setData(
                            ClipboardData(text: _currentCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text(S.of(context).skopirovaneDo)));
                      }
                    }),
                    _actionIcon(Icons.share, S.of(context).zdielatT, () {
                      if (_currentCode != null) {
                        Share.share(
                            'Ahoj, prihlás sa do našej appky Trezor pomocou kódu: $_currentCode');
                      }
                    }),
                    _actionIcon(Icons.refresh, S.of(context).zmenitT,
                        _regenerateCode),
                  ],
                ),
              ]),
            ),

            const SizedBox(height: 24),
            _sectionTitle(S.of(context).mojiT),
            _card(
              child: _companyId == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                stream: _auth.getCompanyEmployees(_companyId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        S.of(context).ziadniTechnici,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final employee =
                      snapshot.data!.docs[index];
                      final email =
                          (employee['email'] as String?) ??
                              'Neznámy email';
                      final isBanned =
                          (employee.data() as Map<String, dynamic>)['banned'] == true;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text(
                            email[0].toUpperCase(),
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                          ),
                        ),
                        title: Text(email),
                        subtitle: Text(isBanned
                            ? S.of(context).odstranenyT
                            : S.of(context).technikT),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isBanned
                                  ? Icons.block
                                  : Icons.check_circle,
                              color: isBanned
                                  ? Colors.red
                                  : Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            if (!isBanned)
                              IconButton(
                                icon: const Icon(
                                    Icons.person_remove_outlined,
                                    color: Colors.red,
                                    size: 22),
                                tooltip: S.of(context).odstranitZFirmy,
                                onPressed: () =>
                                    _removeEmployee(employee),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Pripojenie ──────────────────────────────────────────
          _sectionTitle(S.of(context).pripojenieT),
          _card(
            child: Column(children: [
              _settingsButton(
                title: S.of(context).wifiT,
                icon: Icons.wifi_rounded,
                onTap: () => AppSettings.openAppSettings(
                    type: AppSettingsType.wifi),
              ),
              const Divider(height: 1),
              _settingsButton(
                title: S.of(context).mobilDH,
                icon: Icons.network_cell_rounded,
                onTap: () => AppSettings.openAppSettings(
                    type: AppSettingsType.dataRoaming),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Vzhľad ──────────────────────────────────────────────
          _sectionTitle(S.of(context).vzhladT),
          _card(
            child: Column(children: [
              Text(S.of(context).temaT,
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(S.of(context).systemV),
                      icon: const Icon(Icons.settings_suggest)),
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(S.of(context).setloV),
                      icon: const Icon(Icons.light_mode)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(S.of(context).tmavoV),
                      icon: const Icon(Icons.dark_mode)),
                ],
                selected: {context.watch<ThemeProvider>().themeMode},
                onSelectionChanged: (s) =>
                    context.read<ThemeProvider>().setThemeMode(s.first),
              ),
            ]),
          ),

          const SizedBox(height: 32),

          // ── Odhlásiť ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              onPressed: _handleSignOut,
              icon: const Icon(Icons.logout),
              label: Text(S.of(context).odhlasV),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Pomocné widgety ──────────────────────────────────────────────────────

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)),
  );

  Widget _card({required Widget child}) => Card(
    elevation: 0,
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _settingsButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, size: 20),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      );
}
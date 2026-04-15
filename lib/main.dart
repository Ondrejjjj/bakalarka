import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bakalarka/database.dart';
import 'package:bakalarka/services/sync_service.dart';
import 'package:bakalarka/pages/media_vault_page.dart';
import 'package:bakalarka/theme.dart';
import 'package:bakalarka/settings.dart';
import 'package:bakalarka/camera/camera_page.dart';
import 'package:bakalarka/microphone.dart';
import 'package:bakalarka/pages/login_page.dart';
import 'generated/l10n.dart';
import 'package:bakalarka/pages/inventory_page.dart';
import 'package:bakalarka/pages/assets_management_page.dart';
import 'firebase_options.dart';

import 'theme.dart' hide ThemeProvider, AppTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
  }

  try {
    if (Platform.isAndroid) {
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    }
  } catch (e) {
  }

  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AppDatabase>.value(value: database),
      ],
      child: const MyApp(),
    ),
  );
}

// ── MyApp ─────────────────────────────────────────────────────────────────

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _handleInitialSync();
  }

  Future<void> _handleInitialSync() async {
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = fb.FirebaseAuth.instance.currentUser;

    if (currentUser?.email == null) {
      debugPrint('Žiadny prihlásený používateľ. Synchronizácia sa nespúšťa.');
      return;
    }

    final database = Provider.of<AppDatabase>(context, listen: false);
    final syncService = SyncService(database);
    final userEmail = currentUser!.email!;

    try {
      if (await syncService.isInitialSyncRequired(userEmail)) {

        await syncService.restoreAllUserData();
        await syncService.markInitialSyncAsDone(userEmail);

      } else {

      }


      await syncService.startLiveSync();

    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bakalárska Práca',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            if (settings.name == '/settings') {
              return MaterialPageRoute(builder: (_) => const SettingsPage());
            }
            return null;
          },
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
          home: StreamBuilder<fb.User?>(
            stream: fb.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              return snapshot.hasData ? const MyHomePage() : const LoginPage();
            },
          ),
        );
      },
    );
  }
}

// ── MyHomePage ────────────────────────────────────────────────────────────

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String _userEmail = '';
  String _companyCode = '';

  @override
  void initState() {
    super.initState();
    _loadUserContext();
  }

  Future<void> _loadUserContext() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    final email =
        fbUser?.email ?? await _storage.read(key: 'user_email') ?? '';
    final company = await _storage.read(key: 'company_code') ?? 'GENERAL';
    if (mounted) setState(() { _userEmail = email; _companyCode = company; });
  }

  // ── Navigácia ──────────────────────────────────────────────────────────

  Future<void> _openInventoryPage(BuildContext context,
      {int initialTab = 0}) async {
    final db = context.read<AppDatabase>();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    final localUser = fbUser != null ? await db.getUser(fbUser.uid) : null;
    final email = fbUser?.email ?? _userEmail;
    final company = localUser?.companyCode ?? _companyCode;
    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InventoryPage(
              userEmail: email,
              companyCode: company,
              initialTab: initialTab,
            )));
  }

  Future<void> _openAssetsPage(BuildContext context, {int index = 0}) async {
    final db = context.read<AppDatabase>();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    final localUser = fbUser != null ? await db.getUser(fbUser.uid) : null;
    final email = fbUser?.email ?? _userEmail;
    final company = localUser?.companyCode ?? _companyCode;
    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AssetsManagementPage(
              initialIndex: index,
              userEmail: email,
              companyCode: company,
              database: db,
            )));
  }

  // ── User bottom sheet ─────────────────────────────────────────────────

  void _showUserBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentUser = fb.FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.person,
                      size: 35, color: colorScheme.onPrimaryContainer),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).prihlasenyPouzivatel,
                          style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface)),
                      Text(currentUser?.email ?? 'Neznámy email',
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(height: 32, thickness: 0.5),
            ListTile(
              leading: Icon(Icons.logout_rounded,
                  color: Theme.of(context).colorScheme.error),
              title: Text(S.of(context).odhlasV,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () async {
                Navigator.pop(context);
                await fb.FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: Text(S.of(context).trezorSystem),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _showUserBottomSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 200),
            children: const [],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Prehľady ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).prehladyT,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionTile(
                              icon: Icons.warehouse_outlined,
                              label: S.of(context).stavSkladuT,
                              subtitle: S.of(context).zobrazitZasoby,
                              color: Colors.green,
                              onTap: () =>
                                  _openInventoryPage(context, initialTab: 0),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionTile(
                              icon: Icons.history_outlined,
                              label: S.of(context).historiaMajjetku,
                              subtitle: S.of(context).servisneZaznamy,
                              color: Colors.blueGrey,
                              onTap: () =>
                                  _openAssetsPage(context, index: 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _BottomToolbar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _QuickActionTile ──────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark
          ? color.withValues(alpha: 0.15)
          : color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SettingsDrawer ────────────────────────────────────────────────────────

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  Future<void> _navigateToAssets(BuildContext context, int index) async {
    final database = context.read<AppDatabase>();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) return;
    final localUser = await database.getUser(fbUser.uid);
    final email = fbUser.email ?? 'host@system.sk';
    final company = localUser?.companyCode ?? 'GENERAL';
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AssetsManagementPage(
                initialIndex: index,
                userEmail: email,
                companyCode: company,
                database: database,
              )));
    }
  }


  Future<void> _navigateToInventory(BuildContext context,
      {int initialTab = 0}) async {
    final database = context.read<AppDatabase>();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) return;
    final localUser = await database.getUser(fbUser.uid);
    final email = fbUser.email ?? 'host@system.sk';
    final company = localUser?.companyCode ?? 'GENERAL';
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => InventoryPage(
                userEmail: email,
                companyCode: company,
                initialTab: initialTab, // ← FIX #2
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: Column(children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: colorScheme.primaryContainer),
          currentAccountPicture: CircleAvatar(
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.business_center,
                color: colorScheme.onPrimary, size: 30),
          ),
          accountName: Text(S.of(context).trezorSystem,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          accountEmail: Text(S.of(context).panelText,
              style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _drawerSectionTitle(context, S.of(context).evidenciaText),
              _drawerItem(
                  icon: Icons.inventory_2_outlined,
                  label: S.of(context).zariadeniaText,
                  onTap: () => _navigateToAssets(context, 0)),
              _drawerItem(
                  icon: Icons.history_outlined,
                  label: S.of(context).historiaKText,
                  onTap: () => _navigateToAssets(context, 1)),
              const Divider(indent: 16, endIndent: 16),
              _drawerSectionTitle(context, S.of(context).skladText),
              _drawerItem(
                  icon: Icons.warehouse_outlined,
                  label: S.of(context).stavZText,
                  onTap: () =>
                      _navigateToInventory(context, initialTab: 0)),
              _drawerItem(
                  icon: Icons.swap_vert_rounded,
                  label: S.of(context).pohybyText,
                  onTap: () =>
                      _navigateToInventory(context, initialTab: 1)),
              const Divider(indent: 16, endIndent: 16),
              _drawerSectionTitle(context, S.of(context).systemText),
              _drawerItem(
                  icon: Icons.settings_outlined,
                  label: S.of(context).nastaveniaH,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('v1.0.0-beta',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.outline)),
        ),
      ]),
    );
  }

  Widget _drawerSectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2)),
  );

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
        visualDensity: VisualDensity.compact,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );
}

// ── _BottomToolbar ────────────────────────────────────────────────────────

class _BottomToolbar extends StatelessWidget {
  const _BottomToolbar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _ToolbarItem(
                  icon: Icons.photo_camera_rounded,
                  label: S.of(context).cameraIcon,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CameraPage())),
                ),
                _buildDivider(colorScheme),
                _ToolbarItem(
                  icon: Icons.mic_rounded,
                  label: S.of(context).audioIcon,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const MicrophonePage())),
                ),
                _buildDivider(colorScheme),
                _ToolbarItem(
                  icon: Icons.photo_library_rounded,
                  label: S.of(context).galleryIcon,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const MediaVaultPage())),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme cs) => Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: cs.outlineVariant.withValues(alpha: 0.4));
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
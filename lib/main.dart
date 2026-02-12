import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

// Importy tvojich súborov
import 'package:bakalarka/database.dart';
import 'package:bakalarka/pages/media_vault_page.dart';
import 'package:bakalarka/theme.dart';
import 'package:bakalarka/settings.dart';
import 'package:bakalarka/camera/camera_page.dart';
import 'package:bakalarka/microphone.dart';
import 'package:bakalarka/pages/actions/action_report_pages.dart';
import 'package:bakalarka/pages/login_page.dart';
import 'generated/l10n.dart';
import 'package:bakalarka/pages/inventory_page.dart';
import 'package:bakalarka/pages/assets_management_page.dart';

// Ignorujeme varovania pre schovanie ThemeProvider
import 'theme.dart' hide ThemeProvider, AppTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializácia Firebase
  try {
    await Firebase.initializeApp();
    print("✅ Firebase inicializovaný");
  } catch (e) {
    print("❌ Chyba Firebase: $e");
  }

  // 2. SQLCipher inicializácia
  print("🔧 Inicializujem SQLCipher override...");
  try {
    if (Platform.isAndroid) {
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      print("✅ SQLCipher override úspešný");
    }
  } catch (e) {
    print("❌ Chyba pri override: $e");
  }

  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AppDatabase>.value(value: database), // Databáza je dostupná v celej appke
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },

          home: StreamBuilder<fb.User?>(
            stream: fb.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasData) {
                return const MyHomePage();
              }
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void _showUserBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentUser = fb.FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.person, size: 35, color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prihlásený používateľ',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            currentUser?.email ?? 'Neznámy email',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSheetAction(
                context,
                icon: Icons.badge_outlined,
                label: 'Môj Profil',
                onTap: () => Navigator.pop(context),
              ),
              _buildSheetAction(
                context,
                icon: Icons.settings_outlined,
                label: 'Nastavenia účtu',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 32, thickness: 0.5),

              _buildSheetAction(
                context,
                icon: Icons.logout_rounded,
                label: 'Odhlásiť sa',
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(context);
                  await fb.FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetAction(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionItem(icon: Icons.fact_check, title: "Revízia pred", page: const RevisionBeforePage()),
              _ActionItem(icon: Icons.fact_check_outlined, title: "Revízia po", page: const RevisionAfterPage()),
              _ActionItem(icon: Icons.build, title: "Oprava pred", page: const RepairBeforePage()),
              _ActionItem(icon: Icons.build_circle, title: "Oprava po", page: const RepairAfterPage()),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: const Text('Trezor Bakalárka'),
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
          Column(
            children: [
              const Expanded(
                child: Center(
                  child: Text('Domovská obrazovka', style: TextStyle(fontSize: 18)),
                ),
              ),
              _BottomToolbar(onActionPressed: () {}),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7 > 400 ? 400 : MediaQuery.of(context).size.width * 0.7,
                height: 64,
                child: FloatingActionButton.extended(
                  heroTag: 'mainAction',
                  onPressed: () => _showActionMenu(context),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  elevation: 2,
                  icon: const Icon(Icons.dashboard_customize, size: 28),
                  label: const Text("Akcie", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  // ⭐ POMOCNÁ METÓDA PRE BEZPEČNÚ NAVIGÁCIU S DÁTAMI (MAJETOK)
  Future<void> _navigateToAssets(BuildContext context, int index) async {
    final database = context.read<AppDatabase>();
    final fbUser = fb.FirebaseAuth.instance.currentUser;

    if (fbUser == null) return;

    final localUser = await database.getUser(fbUser.uid);
    final email = fbUser.email ?? 'host@system.sk';
    final company = localUser?.companyCode ?? 'GENERAL';

    if (context.mounted) {
      Navigator.pop(context); // Zatvoriť Drawer
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => AssetsManagementPage(
            initialIndex: index,
            userEmail: email,
            companyCode: company,
            database: database,
          )
      ));
    }
  }

  // ⭐ NOVÁ POMOCNÁ METÓDA PRE SKLAD (INVENTORY)
  Future<void> _navigateToInventory(BuildContext context) async {
    final database = context.read<AppDatabase>();
    final fbUser = fb.FirebaseAuth.instance.currentUser;

    if (fbUser == null) return;

    final localUser = await database.getUser(fbUser.uid);
    final email = fbUser.email ?? 'host@system.sk';
    final company = localUser?.companyCode ?? 'GENERAL';

    if (context.mounted) {
      Navigator.pop(context); // Zatvoriť Drawer
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => InventoryPage(
            userEmail: email,
            companyCode: company,
          )
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primaryContainer),
            currentAccountPicture: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.business_center, color: colorScheme.onPrimary, size: 30),
            ),
            accountName: const Text("Trezor System", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            accountEmail: const Text("Správa majetku a skladu", style: TextStyle(color: Colors.black54)),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerSectionTitle(context, 'Evidencia'),
                _drawerItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Zariadenia',
                  onTap: () => _navigateToAssets(context, 0),
                ),
                _drawerItem(
                  icon: Icons.history_outlined,
                  label: 'História kontrol',
                  onTap: () => _navigateToAssets(context, 1),
                ),
                const Divider(indent: 16, endIndent: 16),
                _drawerSectionTitle(context, 'Sklad'),
                _drawerItem(
                  icon: Icons.warehouse_outlined,
                  label: 'Stav zásob',
                  onTap: () => _navigateToInventory(context), // OPRAVENÉ VOLANIE
                ),
                _drawerItem(
                  icon: Icons.swap_vert_rounded,
                  label: 'Príjem / Výdaj',
                  onTap: () => _navigateToInventory(context), // OPRAVENÉ VOLANIE
                ),
                const Divider(indent: 16, endIndent: 16),
                _drawerSectionTitle(context, 'Systém'),
                _drawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Nastavenia',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0-beta',
              style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _BottomToolbar extends StatelessWidget {
  final VoidCallback onActionPressed;
  const _BottomToolbar({required this.onActionPressed});

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToolbarItem(
                    icon: Icons.photo_camera_rounded,
                    label: 'Kamera',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraPage())),
                  ),
                  _buildDivider(colorScheme),
                  _ToolbarItem(
                    icon: Icons.mic_rounded,
                    label: 'Mikrofón',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MicrophonePage())),
                  ),
                  _buildDivider(colorScheme),
                  _ToolbarItem(
                    icon: Icons.photo_library_rounded,
                    label: 'Galéria',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaVaultPage())),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: colorScheme.outlineVariant.withOpacity(0.4),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;

  const _ActionItem({required this.icon, required this.title, required this.page});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'as fb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

// Importy tvojich súborov (Skontroluj, či názvy priečinkov sedia)
import 'package:bakalarka/database.dart';
import 'package:bakalarka/pages/media_vault_page.dart';
import 'package:bakalarka/theme.dart';
import 'package:bakalarka/settings.dart';
import 'package:bakalarka/camera/camera_page.dart';
import 'package:bakalarka/microphone.dart';
import 'package:bakalarka/pages/actions/action_report_pages.dart';
import 'package:bakalarka/pages/login_page.dart'; // Tvoja nová prihlasovacia stránka
import 'generated/l10n.dart';

// Ignorujeme varovania pre schovanie ThemeProvider, ak ho máš v theme.dart
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
        Provider<AppDatabase>.value(value: database),
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

          // ⭐ DYNAMICKÉ SMEROVANIE (Vrátnik)
          home: StreamBuilder<fb.User?>(
            stream: fb.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              // Ak je prihlásený, ide na domov, inak na login
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

              // ⭐ REÁLNE ODHLÁSENIE
              _buildSheetAction(
                context,
                icon: Icons.logout_rounded,
                label: 'Odhlásiť sa',
                isDestructive: true,
                onTap: () async {
                  // 1. Zatvoríme BottomSheet
                  Navigator.pop(context);

                  // 2. Samotné odhlásenie z Firebase
                  await fb.FirebaseAuth.instance.signOut();

                  // 3. Poistka: Ak by StreamBuilder v MyApp nezareagoval hneď,
                  // vnútime navigáciu na Login.
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Text('Settings', style: TextStyle(fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(S.of(context).settingsTitle),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}

class _BottomToolbar extends StatelessWidget {
  final VoidCallback onActionPressed;

  const _BottomToolbar({required this.onActionPressed});

  @override
  Widget build(BuildContext context) {
    // V M3 používame farby zo schémy, ktoré reagujú na svetlý/tmavý režim
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: ClipRRect( // ClipRRect je nutný, aby blur nepretekal mimo zaoblenia
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efekt rozmazania
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                // Použitie priesvitnej farby povrchu pre efekt skla
                color: colorScheme.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.3), // Jemný okraj
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToolbarItem(
                    icon: Icons.photo_camera_rounded,
                    label: 'Kamera',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraPage())),
                  ),
                  _buildDivider(colorScheme), // Pridal som oddelovač
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

  // Pomocná metóda pre jemný vertikálny oddelovač
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

  const _ToolbarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20), // Aby ripple efekt sedel
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}


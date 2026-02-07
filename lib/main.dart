import 'dart:io';
import 'dart:ui'; // Potrebné pre ImageFilter
import 'package:bakalarka/database.dart';
import 'package:bakalarka/pages/media_vault_page.dart';
import 'package:bakalarka/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'generated/l10n.dart';
import 'settings.dart';
import 'theme.dart' hide ThemeProvider, AppTheme;
import 'package:provider/provider.dart';
import 'camera/camera_page.dart';
import 'microphone.dart';
import 'pages/gallery_page.dart';
import 'pages/actions/action_report_pages.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


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
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        Provider<AppDatabase>.value(
          value: database,
        ),
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
        // Tip: Ak by si pridal balík dynamic_color, tu by si obalil MaterialApp widgetom DynamicColorBuilder
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bakalárska Práca', // Skús dať konkrétny názov

          // TÉMY
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // LOKALIZÁCIA
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales, // Čistejší prístup cez generovaný kód

          // NAVIGÁCIA
          initialRoute: '/',
          // Odporúčam definovať cesty centrálne, aby sa ti kód lepšie udržiaval
          onGenerateRoute: (settings) {
            // Tu môžeš pridať vlastné animácie prechodov (napr. FadeTransition)
            if (settings.name == '/settings') {
              return MaterialPageRoute(builder: (_) => const SettingsPage());
            }
            return null;
          },

          // Builder na globálne nastavenia UI (napr. vypnutie škálovania písma)
          builder: (context, child) {
            return MediaQuery(
              // Zabezpečí, že UI sa nerozbije, ak má používateľ v systéme obrovské písmo
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },

          home: const MyHomePage(),
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

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      // M3 odporúča, aby BottomSheet nebol úplne na celú šírku na veľkých displejoch
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- PROFILOVÁ ČASŤ ---
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
                            'Ondrej Smolarik',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'ondrej@email.com',
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

              // --- AKCIE ---
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
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

// Pomocný widget pre krajšie tlačidlá v menu
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
              _ActionItem(
                icon: Icons.fact_check,
                title: "Revízia pred",
                page: const RevisionBeforePage(),
              ),
              _ActionItem(
                icon: Icons.fact_check_outlined,
                title: "Revízia po",
                page: const RevisionAfterPage(),
              ),
              _ActionItem(
                icon: Icons.build,
                title: "Oprava pred",
                page: const RepairBeforePage(),
              ),
              _ActionItem(
                icon: Icons.build_circle,
                title: "Oprava po",
                page: const RepairAfterPage(),
              ),
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
        title: const Text('Flutter App'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
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
                  child: Text(
                    'Domovská obrazovka',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              _BottomToolbar(
                onActionPressed: () {},
              ),
            ],
          ),
          /// ⭐ VEĽKÉ AKČNÉ TLAČIDLO (M3 ŠTÝL)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                // Responzívna šírka, ale s rozumným maximom pre tablety
                width: MediaQuery.of(context).size.width * 0.7 > 400
                    ? 400
                    : MediaQuery.of(context).size.width * 0.7,
                height: 64, // Fixnejšia výška pôsobí stabilnejšie
                child: FloatingActionButton.extended(
                  heroTag: 'mainAction', // Dobré mať pre plynulé prechody
                  onPressed: () => _showActionMenu(context),

                  // M3 farby - toto tlacidlo bude vizualne dominovat
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,

                  elevation: 2, // M3 preferuje nižší tieň (tonal elevation)

                  icon: const Icon(Icons.dashboard_customize, size: 28),
                  label: const Text(
                    "Akcie",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  // Zaoblenie rohov podľa M3 (viac hranaté ako kruh, ale stále oblé)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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


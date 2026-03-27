import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' as d;

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
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('✅ Firebase inicializovaný');
  } catch (e) {
    debugPrint('❌ Chyba Firebase: $e');
  }

  try {
    if (Platform.isAndroid) {
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      debugPrint('✅ SQLCipher override úspešný');
    }
  } catch (e) {
    debugPrint('❌ Chyba pri override: $e');
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
    if (currentUser?.email == null) return;

    final database = Provider.of<AppDatabase>(context, listen: false);
    final syncService = SyncService(database);
    final userEmail = currentUser!.email!;

    if (await syncService.isInitialSyncRequired(userEmail)) {
      debugPrint('🚀 Prvé spustenie pre $userEmail, spúšťam restore...');
      await syncService.restoreAllUserData();
      await syncService.markInitialSyncAsDone(userEmail);
      debugPrint('✅ Sync pre $userEmail dokončený.');
    } else {
      debugPrint('🏠 Používateľ $userEmail má dáta. Preskakujem.');
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
    final company =
        await _storage.read(key: 'company_code') ?? 'GENERAL';
    if (mounted) {
      setState(() {
        _userEmail = email;
        _companyCode = company;
      });
    }
  }

  // ── Navigácia ──────────────────────────────────────────────────────────

  Future<void> _openInventoryPage(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    final localUser = fbUser != null ? await db.getUser(fbUser.uid) : null;
    final email = fbUser?.email ?? _userEmail;
    final company = localUser?.companyCode ?? _companyCode;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              InventoryPage(userEmail: email, companyCode: company)),
    );
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
          )),
    );
  }

  // ── Rýchly skladový pohyb ─────────────────────────────────────────────

  void _showQuickMovementSheet(BuildContext context) {
    final db = context.read<AppDatabase>();
    if (_companyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Najskôr sa prihláste do firmy.')));
      return;
    }

    bool isIncome = true;
    InventoryData? selectedItem;
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Icon(Icons.swap_vert_rounded,
                      color: Theme.of(ctx).colorScheme.primary, size: 26),
                  const SizedBox(width: 10),
                  const Text('Rýchly skladový pohyb',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 20),

                // Výdaj / Príjem
                Row(children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Výdaj')),
                      selected: !isIncome,
                      selectedColor: Colors.red.withValues(alpha: 0.2),
                      onSelected: (_) => setModal(() => isIncome = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Príjem')),
                      selected: isIncome,
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                      onSelected: (_) => setModal(() => isIncome = true),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Autocomplete položky
                StreamBuilder<List<InventoryData>>(
                  stream: db.watchCompanyInventory(_companyCode),
                  builder: (ctx, snap) {
                    final items = snap.data ?? [];
                    return Autocomplete<InventoryData>(
                      displayStringForOption: (i) => i.name,
                      optionsBuilder: (tv) => tv.text.isEmpty
                          ? items
                          : items.where((i) => i.name
                          .toLowerCase()
                          .contains(tv.text.toLowerCase())),
                      onSelected: (sel) =>
                          setModal(() => selectedItem = sel),
                      fieldViewBuilder: (ctx, ctrl, fn, _) => TextField(
                        controller: ctrl,
                        focusNode: fn,
                        decoration: const InputDecoration(
                          labelText: 'Položka skladu',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Množstvo
                TextField(
                  controller: qtyCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Množstvo',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 12),

                // Poznámka
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Poznámka (voliteľné)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(isIncome ? Icons.add : Icons.remove),
                    label: Text(isIncome
                        ? 'POTVRDIŤ PRÍJEM'
                        : 'POTVRDIŤ VÝDAJ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isIncome ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final amount =
                          double.tryParse(qtyCtrl.text) ?? 0.0;
                      if (selectedItem == null || amount <= 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Vyberte položku a zadajte množstvo.')));
                        return;
                      }
                      final changeQty = isIncome ? amount : -amount;
                      final movement = StockMovementsCompanion.insert(
                        inventoryId: selectedItem!.id,
                        itemName: selectedItem!.name,
                        changeQty: changeQty,
                        type: isIncome ? 'income' : 'outcome',
                        extraData: d.Value(jsonEncode(
                            noteCtrl.text.isNotEmpty
                                ? {'poznamka': noteCtrl.text}
                                : {})),
                        userEmail: _userEmail,
                        companyCode: _companyCode,
                        createdAt: d.Value(DateTime.now()),
                      );
                      await db.registerMovement(selectedItem!, movement);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '${isIncome ? "Príjem" : "Výdaj"} ${selectedItem!.name} '
                                  '(${changeQty > 0 ? "+" : ""}$changeQty) zaznamenaný.'),
                        ));
                      }
                    },
                  ),
                ),

                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Otvoriť plný sklad'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openInventoryPage(context);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Rýchle pridanie zariadenia ────────────────────────────────────────

  void _showQuickAddAssetDialog(BuildContext context) {
    final db = context.read<AppDatabase>();
    if (_companyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Najskôr sa prihláste do firmy.')));
      return;
    }

    final nameCtrl = TextEditingController();
    final snCtrl = TextEditingController();
    final modelCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Icon(Icons.precision_manufacturing_outlined,
                    color: Theme.of(ctx).colorScheme.primary, size: 26),
                const SizedBox(width: 10),
                const Text('Rýchle pridanie zariadenia',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 20),

              _quickField(nameCtrl, 'Názov zariadenia *',
                  hint: 'napr. Kompresor'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: _quickField(snCtrl, 'Sériové číslo *',
                        hint: 'SN-001')),
                const SizedBox(width: 10),
                Expanded(
                    child: _quickField(modelCtrl, 'Model',
                        hint: 'napr. GA 15')),
              ]),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('ULOŽIŤ ZARIADENIE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty ||
                        snCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Názov a sériové číslo sú povinné.')));
                      return;
                    }
                    await db.upsertAsset(AssetsCompanion.insert(
                      name: nameCtrl.text.trim(),
                      sn: snCtrl.text.trim(),
                      model: modelCtrl.text.trim(),
                      status: 'V prevádzke',
                      techSpecs: jsonEncode({}),
                      history: jsonEncode([
                        {
                          'date': DateTime.now()
                              .toString()
                              .split(' ')[0],
                          'action': 'Pridanie',
                          'note':
                          'Zariadenie zaevidované cez rýchlu akciu',
                        }
                      ]),
                      userEmail: _userEmail,
                      companyCode: _companyCode,
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '"${nameCtrl.text.trim()}" bolo pridané.')));
                    }
                  },
                ),
              ),

              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Otvoriť evidenciu majetku'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openAssetsPage(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
                      size: 35,
                      color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prihlásený používateľ',
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
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              children: [
                // ── Rýchle akcie ──────────────────────────────────────
                Text(
                  'Rýchle akcie',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.swap_vert_rounded,
                      label: 'Nový pohyb skladu',
                      subtitle: 'Príjem / výdaj',
                      color: Colors.teal,
                      onTap: () => _showQuickMovementSheet(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.add_box_outlined,
                      label: 'Pridať zariadenie',
                      subtitle: 'Evidencia majetku',
                      color: Colors.indigo,
                      onTap: () => _showQuickAddAssetDialog(context),
                    ),
                  ),
                ]),

                const SizedBox(height: 28),

                // ── Prehľady ───────────────────────────────────────────
                Text(
                  'Prehľady',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.warehouse_outlined,
                      label: 'Stav skladu',
                      subtitle: 'Zobraziť zásoby',
                      color: Colors.green,
                      onTap: () => _openInventoryPage(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.history_outlined,
                      label: 'História majetku',
                      subtitle: 'Servisné záznamy',
                      color: Colors.blueGrey,
                      onTap: () => _openAssetsPage(context, index: 1),
                    ),
                  ),
                ]),

                // padding pre toolbar
                const SizedBox(height: 120),
              ],
            ),
          ),
          _BottomToolbar(),
        ],
      ),
    );
  }

  Widget _quickField(TextEditingController ctrl, String label,
      {String? hint}) =>
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
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

  Future<void> _navigateToInventory(BuildContext context) async {
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
          accountName: const Text('Trezor System',
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
                  onTap: () => _navigateToInventory(context)),
              _drawerItem(
                  icon: Icons.swap_vert_rounded,
                  label: S.of(context).pohybyText,
                  onTap: () => _navigateToInventory(context)),
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

  Widget _drawerSectionTitle(BuildContext context, String title) =>
      Padding(
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                    color: colorScheme.outlineVariant
                        .withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _ToolbarItem(
                  icon: Icons.photo_camera_rounded,
                  label: S.of(context).cameraIcon,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CameraPage())),
                ),
                _buildDivider(colorScheme),
                _ToolbarItem(
                  icon: Icons.mic_rounded,
                  label: S.of(context).audioIcon,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MicrophonePage())),
                ),
                _buildDivider(colorScheme),
                _ToolbarItem(
                  icon: Icons.photo_library_rounded,
                  label: S.of(context).galleryIcon,
                  onTap: () => Navigator.push(
                      context,
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
          Icon(icon,
              size: 26, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant)),
        ]),
      ),
    );
  }
}
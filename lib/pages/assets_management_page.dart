import 'dart:convert';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as d;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssetsManagementPage extends StatefulWidget {
  final int initialIndex;
  final String userEmail;
  final String companyCode;
  final AppDatabase database;

  const AssetsManagementPage({
    super.key,
    this.initialIndex = 0,
    required this.userEmail,
    required this.companyCode,
    required this.database,
  });

  @override
  State<AssetsManagementPage> createState() => _AssetsManagementPageState();
}

class _AssetsManagementPageState extends State<AssetsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAscending = true;
  bool _isSyncing = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeStatusFilter;

  bool _isOnline = true;

  static const List<String> _allStatuses = [
    'V prevádzke',
    'Vyžaduje servis',
    'V poruche',
    'Odstavené',
    'Vyradené',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });

    Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) setState(() => _isOnline = result != ConnectivityResult.none);
    });
    Connectivity()
        .checkConnectivity()
        .then((r) => mounted ? setState(() => _isOnline = r != ConnectivityResult.none) : null);

    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAssetsFromCloud());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  Future<void> _refreshAssetsFromCloud() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await SyncService(widget.database).restoreAllUserData();
    } catch (e) {
      debugPrint('❌ Sync chyba: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // ── Filter ────────────────────────────────────────────────────────────────

  List<Asset> _filterAssets(List<Asset> all) {
    var list = all;
    if (_activeStatusFilter != null) {
      list = list.where((a) => a.status == _activeStatusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((a) =>
      a.name.toLowerCase().contains(_searchQuery) ||
          a.sn.toLowerCase().contains(_searchQuery) ||
          a.model.toLowerCase().contains(_searchQuery) ||
          (a.url ?? '').toLowerCase().contains(_searchQuery))
          .toList();
    }
    list.sort((a, b) =>
    _isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return list;
  }

  // ── DB + Firebase ─────────────────────────────────────────────────────────

  Future<void> _saveAssetToDbAndFirebase(AssetsCompanion assetCompanion) async {
    final localId = await widget.database.upsertAsset(assetCompanion);
    if (!_isOnline) return;
    try {
      final data = {
        'name': assetCompanion.name.value,
        'sn': assetCompanion.sn.value,
        'model': assetCompanion.model.value,
        'url': assetCompanion.url.value,
        'status': assetCompanion.status.value,
        'techSpecs': jsonDecode(assetCompanion.techSpecs.value),
        'history': jsonDecode(assetCompanion.history.value),
        'userEmail': widget.userEmail,
        'companyCode': widget.companyCode,
        'lastModified': DateTime.now().toIso8601String(),
      };
      String? fId = assetCompanion.firebaseId.value;
      if (fId == null) {
        final ref = await FirebaseFirestore.instance.collection('assets').add(data);
        fId = ref.id;
      } else {
        await FirebaseFirestore.instance.collection('assets').doc(fId).update(data);
      }
      await widget.database.markAssetAsSynced(localId, fId);
    } catch (e) {
      debugPrint('Firebase sync chyba: $e');
    }
  }

  Future<void> _deleteAsset(Asset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vymazať zariadenie?'),
        content: Text('Naozaj chcete vymazať "${asset.name}"?\nTáto akcia je nevratná.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Zrušiť')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Vymazať', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await widget.database.deleteAsset(asset.id);
    if (asset.firebaseId != null && _isOnline) {
      try {
        await FirebaseFirestore.instance.collection('assets').doc(asset.firebaseId).delete();
      } catch (e) {
        debugPrint('Firebase mazanie chyba: $e');
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('"${asset.name}" bol vymazaný.')));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _getStatusColor(String status) {
    switch (status) {
      case 'V prevádzke':    return Colors.green;
      case 'Vyžaduje servis': return Colors.orange;
      case 'V poruche':      return Colors.deepOrange;
      case 'Odstavené':      return Colors.blueGrey;
      case 'Vyradené':       return Colors.red;
      default:               return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'V prevádzke':    return Icons.check_circle_outline;
      case 'Vyžaduje servis': return Icons.build_outlined;
      case 'V poruche':      return Icons.warning_amber_outlined;
      case 'Odstavené':      return Icons.pause_circle_outline;
      case 'Vyradené':       return Icons.cancel_outlined;
      default:               return Icons.help_outline;
    }
  }

  // ── Dialógy ───────────────────────────────────────────────────────────────

  /// Rozšírený dialóg pridania zariadenia – využíva všetky polia z DB
  void _showAddAssetDialog(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final snCtrl    = TextEditingController();
    final modelCtrl = TextEditingController();
    final urlCtrl   = TextEditingController();
    String selectedStatus = 'V prevádzke';
    // Počiatočné technické parametre – používateľ môže pridať ľubovoľne
    List<Map<String, TextEditingController>> specFields = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ťahadlo
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nadpis
                  Row(children: [
                    Icon(Icons.add_box_outlined,
                        color: Theme.of(ctx).colorScheme.primary, size: 26),
                    const SizedBox(width: 10),
                    const Text('Nové zariadenie',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 20),

                  // ── Základné údaje ──
                  _sectionLabel('Základné údaje'),
                  const SizedBox(height: 8),
                  _field(nameCtrl,  'Názov zariadenia *', hint: 'napr. Kompresor Atlas'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _field(snCtrl,    'Sériové číslo *', hint: 'napr. SN-001')),
                    const SizedBox(width: 10),
                    Expanded(child: _field(modelCtrl, 'Model',           hint: 'napr. GA 15')),
                  ]),
                  const SizedBox(height: 10),
                  _field(urlCtrl, 'Odkaz / URL', hint: 'napr. manuál, e-shop…',
                      icon: Icons.link, keyboardType: TextInputType.url),

                  const SizedBox(height: 16),

                  // ── Počiatočný stav ──
                  _sectionLabel('Počiatočný stav'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _allStatuses.map((s) {
                      final c = _getStatusColor(s);
                      return DropdownMenuItem(
                        value: s,
                        child: Row(children: [
                          Icon(_getStatusIcon(s), color: c, size: 18),
                          const SizedBox(width: 8),
                          Text(s, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }).toList(),
                    onChanged: (v) => setModal(() => selectedStatus = v!),
                  ),

                  const SizedBox(height: 16),

                  // ── Technické parametre ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('Technické parametre'),
                      TextButton.icon(
                        onPressed: () => setModal(() => specFields.add({
                          'key': TextEditingController(),
                          'value': TextEditingController(),
                        })),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Pridať'),
                      ),
                    ],
                  ),
                  if (specFields.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Žiadne parametre – kliknite Pridať',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    )
                  else
                    ...specFields.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Expanded(
                            child: TextField(
                                controller: f['key'],
                                decoration: const InputDecoration(
                                    hintText: 'Názov', isDense: true,
                                    border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextField(
                                controller: f['value'],
                                decoration: const InputDecoration(
                                    hintText: 'Hodnota', isDense: true,
                                    border: OutlineInputBorder()))),
                        IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 20),
                            onPressed: () => setModal(() => specFields.remove(f))),
                      ]),
                    )),

                  const SizedBox(height: 20),

                  // ── Tlačidlo uložiť ──
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
                                    'Názov a sériové číslo sú povinné.')),
                          );
                          return;
                        }

                        // Zozbieraj technické parametre
                        final Map<String, dynamic> specs = {};
                        for (final f in specFields) {
                          if (f['key']!.text.trim().isNotEmpty) {
                            specs[f['key']!.text.trim()] =
                                f['value']!.text.trim();
                          }
                        }

                        final newAsset = AssetsCompanion.insert(
                          name:        nameCtrl.text.trim(),
                          sn:          snCtrl.text.trim(),
                          model:       modelCtrl.text.trim(),
                          url:         d.Value(urlCtrl.text.trim().isEmpty
                              ? null
                              : urlCtrl.text.trim()),
                          status:      selectedStatus,
                          techSpecs:   jsonEncode(specs),
                          history: jsonEncode([
                            {
                              'date': DateTime.now().toString().split(' ')[0],
                              'action': 'Pridanie',
                              'note':
                              'Zariadenie bolo zaevidované do systému',
                            }
                          ]),
                          userEmail:   widget.userEmail,
                          companyCode: widget.companyCode,
                        );

                        await _saveAssetToDbAndFirebase(newAsset);
                        if (mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditAssetDialog(Asset asset) {
    final noteCtrl = TextEditingController();
    String currentStatus = asset.status;
    Map<String, dynamic> currentSpecs = jsonDecode(asset.techSpecs);
    List<Map<String, TextEditingController>> newSpecFields = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Icon(Icons.build_circle_outlined,
                      color: Theme.of(ctx).colorScheme.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Servis: ${asset.name}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 20),

                _sectionLabel('Zmena stavu'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: currentStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: _allStatuses.map((s) {
                    final c = _getStatusColor(s);
                    return DropdownMenuItem(
                      value: s,
                      child: Row(children: [
                        Icon(_getStatusIcon(s), color: c, size: 18),
                        const SizedBox(width: 8),
                        Text(s,
                            style: TextStyle(
                                color: c, fontWeight: FontWeight.w600)),
                      ]),
                    );
                  }).toList(),
                  onChanged: (v) => setModal(() => currentStatus = v!),
                ),

                const SizedBox(height: 16),
                _sectionLabel('Poznámka k servisu'),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Napr. Vymenené tesnenie...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Doplniť parametre'),
                    TextButton.icon(
                      onPressed: () => setModal(() => newSpecFields.add({
                        'key': TextEditingController(),
                        'value': TextEditingController(),
                      })),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nové pole'),
                    ),
                  ],
                ),
                ...newSpecFields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                            controller: f['key'],
                            decoration: const InputDecoration(
                                hintText: 'Názov', isDense: true,
                                border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: f['value'],
                            decoration: const InputDecoration(
                                hintText: 'Hodnota', isDense: true,
                                border: OutlineInputBorder()))),
                    IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 20),
                        onPressed: () =>
                            setModal(() => newSpecFields.remove(f))),
                  ]),
                )),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('ULOŽIŤ ZMENY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      for (final f in newSpecFields) {
                        if (f['key']!.text.trim().isNotEmpty) {
                          currentSpecs[f['key']!.text.trim()] =
                              f['value']!.text.trim();
                        }
                      }
                      final List<dynamic> historyList =
                      jsonDecode(asset.history);
                      if (noteCtrl.text.isNotEmpty ||
                          currentStatus != asset.status) {
                        historyList.insert(0, {
                          'date': DateTime.now().toString().split(' ')[0],
                          'action': 'Úprava / Servis',
                          'note': noteCtrl.text.isEmpty
                              ? 'Zmena stavu na: $currentStatus'
                              : noteCtrl.text,
                        });
                      }
                      await _saveAssetToDbAndFirebase(AssetsCompanion(
                        id:          d.Value(asset.id),
                        firebaseId:  d.Value(asset.firebaseId),
                        name:        d.Value(asset.name),
                        sn:          d.Value(asset.sn),
                        model:       d.Value(asset.model),
                        url:         d.Value(asset.url),
                        status:      d.Value(currentStatus),
                        techSpecs:   d.Value(jsonEncode(currentSpecs)),
                        history:     d.Value(jsonEncode(historyList)),
                        userEmail:   d.Value(widget.userEmail),
                        companyCode: d.Value(widget.companyCode),
                        lastModified: d.Value(DateTime.now()),
                      ));
                      if (mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTechDetailsSheet(Asset asset) {
    final Map<String, dynamic> specs = jsonDecode(asset.techSpecs);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(asset.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            // URL ak existuje
            if ((asset.url ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  // url_launcher – ak ho máš v projekte
                  // launchUrl(Uri.parse(asset.url!));
                },
                child: Text(
                  asset.url!,
                  style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const Divider(height: 20),
            if (specs.isEmpty)
              const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Žiadne technické parametre'),
                  ))
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: specs.entries
                      .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(e.key,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13))),
                        const SizedBox(width: 16),
                        Text(e.value.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia majetku'),
        actions: [
          if (!_isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Bez pripojenia – zmeny sa uložia lokálne',
                child: Icon(Icons.cloud_off, color: Colors.orange[300], size: 20),
              ),
            ),
          IconButton(
            icon: Icon(_isAscending
                ? Icons.sort_by_alpha
                : Icons.sort_by_alpha_outlined),
            tooltip: _isAscending ? 'Zoradiť Z–A' : 'Zoradiť A–Z',
            onPressed: () => setState(() => _isAscending = !_isAscending),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.precision_manufacturing_outlined), text: 'Zariadenia'),
            Tab(icon: Icon(Icons.history), text: 'História'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isSyncing) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAssetsList(), _buildGlobalHistory()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAssetDialog(context),
        label: const Text('Pridať zariadenie'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAssetsList() {
    return Column(
      children: [
        // Vyhľadávanie
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Hľadať podľa názvu, S/N, modelu...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _searchController.clear())
                  : null,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
        ),

        // Filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: const Text('Všetky'),
                  selected: _activeStatusFilter == null,
                  onSelected: (_) => setState(() => _activeStatusFilter = null),
                ),
              ),
              ..._allStatuses.map((s) {
                final c = _getStatusColor(s);
                final active = _activeStatusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    avatar: Icon(_getStatusIcon(s),
                        size: 16, color: active ? c : Colors.grey),
                    label: Text(s),
                    selected: active,
                    selectedColor: c.withOpacity(0.15),
                    checkmarkColor: c,
                    side: BorderSide(color: active ? c : Colors.transparent),
                    onSelected: (_) => setState(() =>
                    _activeStatusFilter = active ? null : s),
                  ),
                );
              }),
            ],
          ),
        ),

        // Zoznam
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshAssetsFromCloud,
            child: StreamBuilder<List<Asset>>(
              stream: widget.database.watchCompanyAssets(widget.companyCode),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = _filterAssets(snap.data ?? []);
                if (list.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Column(children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty ||
                                _activeStatusFilter != null
                                ? 'Žiadne výsledky pre zadaný filter.'
                                : 'Žiadny majetok vo firme.',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ]),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _buildAssetCard(list[i]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(Asset asset) {
    final statusColor = _getStatusColor(asset.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyBg = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final historyFg = isDark ? Colors.grey[300]! : Colors.grey[800]!;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.12),
          child: Icon(_getStatusIcon(asset.status), size: 18, color: statusColor),
        ),
        title: Text(asset.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
        subtitle: Wrap(spacing: 8, children: [
          Text(asset.status,
              style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.bold)),
          Text('S/N: ${asset.sn}', style: const TextStyle(fontSize: 11)),
          if (asset.model.isNotEmpty)
            Text(asset.model,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            asset.isUploaded ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: asset.isUploaded ? Colors.blue : Colors.orange,
          ),
          const Icon(Icons.expand_more),
        ]),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),

                // Akcie
                Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showEditAssetDialog(asset),
                      icon: const Icon(Icons.build, size: 16),
                      label: const Text('Servis / Úprava'),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _showTechDetailsSheet(asset),
                    icon: const Icon(Icons.list_alt),
                    tooltip: 'Technické parametre',
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _deleteAsset(asset),
                    icon: const Icon(Icons.delete_outline),
                    style: IconButton.styleFrom(foregroundColor: Colors.red),
                    tooltip: 'Vymazať zariadenie',
                  ),
                ]),

                // Posledný servisný záznam
                Builder(builder: (_) {
                  final history = jsonDecode(asset.history) as List<dynamic>;
                  if (history.isEmpty) return const SizedBox();
                  final last = history[0];
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: historyBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.history,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${last['date']}  ·  ${last['note']}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: historyFg),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalHistory() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _refreshAssetsFromCloud,
      child: StreamBuilder<List<Asset>>(
        stream: widget.database.watchCompanyAssets(widget.companyCode),
        builder: (_, snap) {
          if (!snap.hasData) return const SizedBox();

          final List<Map<String, dynamic>> all = [];
          for (final asset in snap.data!) {
            for (final entry in jsonDecode(asset.history) as List<dynamic>) {
              all.add({
                'assetName': asset.name,
                'date':   entry['date']   ?? '',
                'action': entry['action'] ?? '',
                'note':   entry['note']   ?? '',
              });
            }
          }
          all.sort((a, b) => (b['date'] as String).compareTo(a['date']));

          if (all.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(child: Text('História je prázdna.')),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: all.length,
            itemBuilder: (_, i) {
              final item = all[i];
              final isLast = i == all.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Časová os
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Obsah
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dátum – explicitná farba aby nebolo biele na bielom
                            Text(
                              item['date'],
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Názov zariadenia
                            Text(
                              item['assetName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey[900],
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Typ akcie
                            Text(
                              item['action'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Poznámka
                            Text(
                              item['note'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Pomocné widgety ───────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
  );

  Widget _field(
      TextEditingController ctrl,
      String label, {
        String? hint,
        IconData? icon,
        TextInputType? keyboardType,
      }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
}
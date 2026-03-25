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

  // --- NOVÉ: Vyhľadávanie a filter ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeStatusFilter; // null = všetky

  // --- NOVÉ: Stav pripojenia ---
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

    // Sledovanie pripojenia
    Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() => _isOnline = result != ConnectivityResult.none);
      }
    });
    Connectivity().checkConnectivity().then((result) {
      if (mounted) setState(() => _isOnline = result != ConnectivityResult.none);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAssetsFromCloud();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAssetsFromCloud() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      final syncService = SyncService(widget.database);
      await syncService.restoreAllUserData();
    } catch (e) {
      debugPrint('❌ Chyba pri synchronizácii majetku: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // --- Filtrovanie zoznamu ---
  List<Asset> _filterAssets(List<Asset> all) {
    var list = all;

    // Filter podľa stavu
    if (_activeStatusFilter != null) {
      list = list.where((a) => a.status == _activeStatusFilter).toList();
    }

    // Fulltext search v názve a S/N
    if (_searchQuery.isNotEmpty) {
      list = list.where((a) =>
      a.name.toLowerCase().contains(_searchQuery) ||
          a.sn.toLowerCase().contains(_searchQuery) ||
          a.model.toLowerCase().contains(_searchQuery)).toList();
    }

    list.sort((a, b) =>
    _isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

    return list;
  }

  // --- DB + Firebase ---

  Future<void> _saveAssetToDbAndFirebase(AssetsCompanion assetCompanion) async {
    final localId = await widget.database.upsertAsset(assetCompanion);

    if (!_isOnline) return;

    try {
      final firestoreData = {
        'name': assetCompanion.name.value,
        'sn': assetCompanion.sn.value,
        'model': assetCompanion.model.value,
        'status': assetCompanion.status.value,
        'techSpecs': jsonDecode(assetCompanion.techSpecs.value),
        'history': jsonDecode(assetCompanion.history.value),
        'userEmail': widget.userEmail,
        'companyCode': widget.companyCode,
        'lastModified': DateTime.now().toIso8601String(),
      };

      String? fId = assetCompanion.firebaseId.value;
      if (fId == null) {
        final docRef = await FirebaseFirestore.instance
            .collection('assets')
            .add(firestoreData);
        fId = docRef.id;
      } else {
        await FirebaseFirestore.instance
            .collection('assets')
            .doc(fId)
            .update(firestoreData);
      }

      await widget.database.markAssetAsSynced(localId, fId);
    } catch (e) {
      debugPrint('Chyba pri Firebase synchre: $e');
    }
  }

  // --- NOVÉ: Vymazanie majetku ---
  Future<void> _deleteAsset(Asset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vymazať zariadenie?'),
        content: Text(
            'Naozaj chcete vymazať "${asset.name}"?\nTáto akcia je nevratná.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
            const Text('Vymazať', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await widget.database.deleteAsset(asset.id);

    // Ak má Firebase ID a sme online, zmazať aj z Firestore
    if (asset.firebaseId != null && _isOnline) {
      try {
        await FirebaseFirestore.instance
            .collection('assets')
            .doc(asset.firebaseId)
            .delete();
      } catch (e) {
        debugPrint('Chyba pri mazaní z Firebase: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${asset.name}" bol vymazaný.')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'V prevádzke':
        return Colors.green;
      case 'Vyžaduje servis':
        return Colors.orange;
      case 'V poruche':
        return Colors.deepOrange;
      case 'Odstavené':
        return Colors.blueGrey;
      case 'Vyradené':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // --- DIALÓGY ---

  void _showEditAssetDialog(Asset asset) {
    final TextEditingController noteController = TextEditingController();
    String currentStatus = asset.status;
    Map<String, dynamic> currentSpecs = jsonDecode(asset.techSpecs);
    List<Map<String, TextEditingController>> newSpecFields = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
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
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.build_circle_outlined,
                        color: Theme.of(context).colorScheme.primary, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text('Servis: ${asset.name}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Aktuálny stav:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: currentStatus,
                  decoration:
                  const InputDecoration(border: OutlineInputBorder()),
                  items: _allStatuses
                      .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => currentStatus = val!),
                ),
                const SizedBox(height: 16),
                const Text('Poznámka k servisu:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      hintText: 'Napr. Vymenené tesnenie...',
                      border: OutlineInputBorder()),
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Doplniť parametre',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => setModalState(() {
                        newSpecFields.add({
                          'key': TextEditingController(),
                          'value': TextEditingController()
                        });
                      }),
                      icon: const Icon(Icons.add),
                      label: const Text('Nové pole'),
                    ),
                  ],
                ),
                if (newSpecFields.isNotEmpty)
                  ...newSpecFields.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: field['key'],
                                decoration: const InputDecoration(
                                    hintText: 'Názov', isDense: true))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextField(
                                controller: field['value'],
                                decoration: const InputDecoration(
                                    hintText: 'Hodnota', isDense: true))),
                        IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => setModalState(
                                    () => newSpecFields.remove(field)))
                      ],
                    ),
                  )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      for (var f in newSpecFields) {
                        if (f['key']!.text.isNotEmpty) {
                          currentSpecs[f['key']!.text] = f['value']!.text;
                        }
                      }
                      List<dynamic> historyList = jsonDecode(asset.history);
                      if (noteController.text.isNotEmpty ||
                          currentStatus != asset.status) {
                        historyList.insert(0, {
                          'date':
                          DateTime.now().toString().split(' ')[0],
                          'action': 'Úprava / Servis',
                          'note': noteController.text.isEmpty
                              ? 'Zmena stavu na: $currentStatus'
                              : noteController.text,
                        });
                      }
                      final updatedAsset = AssetsCompanion(
                        id: d.Value(asset.id),
                        firebaseId: d.Value(asset.firebaseId),
                        name: d.Value(asset.name),
                        sn: d.Value(asset.sn),
                        model: d.Value(asset.model),
                        status: d.Value(currentStatus),
                        techSpecs: d.Value(jsonEncode(currentSpecs)),
                        history: d.Value(jsonEncode(historyList)),
                        userEmail: d.Value(widget.userEmail),
                        companyCode: d.Value(widget.companyCode),
                        lastModified: d.Value(DateTime.now()),
                      );
                      await _saveAssetToDbAndFirebase(updatedAsset);
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('ULOŽIŤ ZMENY'),
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

  void _showAddAssetDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final snCtrl = TextEditingController();
    final modelCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nové zariadenie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration:
                const InputDecoration(labelText: 'Názov (napr. Kotol)')),
            TextField(
                controller: snCtrl,
                decoration:
                const InputDecoration(labelText: 'Sériové číslo')),
            TextField(
                controller: modelCtrl,
                decoration: const InputDecoration(labelText: 'Model')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Zrušiť')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || snCtrl.text.isEmpty) return;
              final newAsset = AssetsCompanion.insert(
                name: nameCtrl.text,
                sn: snCtrl.text,
                model: modelCtrl.text,
                status: 'V prevádzke',
                techSpecs: jsonEncode({}),
                history: jsonEncode([
                  {
                    'date': DateTime.now().toString().split(' ')[0],
                    'action': 'Pridanie',
                    'note': 'Zariadenie bolo zaevidované do systému'
                  }
                ]),
                userEmail: widget.userEmail,
                companyCode: widget.companyCode,
              );
              await _saveAssetToDbAndFirebase(newAsset);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Pridať'),
          )
        ],
      ),
    );
  }

  void _showTechDetailsSheet(String assetName, String techSpecsJson) {
    final Map<String, dynamic> specs = jsonDecode(techSpecsJson);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assetName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (specs.isEmpty)
              const Center(child: Text('Žiadne parametre'))
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: specs.entries
                      .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(e.key,
                                style: const TextStyle(
                                    color: Colors.grey))),
                        Text(e.value.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
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

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia majetku'),
        actions: [
          // NOVÉ: Offline indikátor
          if (!_isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Bez pripojenia – zmeny sa uložia lokálne',
                child: Icon(Icons.cloud_off,
                    color: Colors.orange[300], size: 20),
              ),
            ),
          IconButton(
            icon: Icon(_isAscending
                ? Icons.sort_by_alpha
                : Icons.sort_by_alpha_outlined),
            onPressed: () => setState(() => _isAscending = !_isAscending),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
                icon: Icon(Icons.precision_manufacturing_outlined),
                text: 'Zariadenia'),
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
              children: [
                _buildAssetsList(),
                _buildGlobalHistory(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAssetDialog(context),
        label: const Text('Pridať'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAssetsList() {
    return Column(
      children: [
        // --- NOVÉ: Vyhľadávací panel ---
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
                onPressed: () => _searchController.clear(),
              )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
        ),

        // --- NOVÉ: Filter chips podľa stavu ---
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              // Chip "Všetky"
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: const Text('Všetky'),
                  selected: _activeStatusFilter == null,
                  onSelected: (_) =>
                      setState(() => _activeStatusFilter = null),
                ),
              ),
              ..._allStatuses.map((status) {
                final color = _getStatusColor(status);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(status),
                    selected: _activeStatusFilter == status,
                    selectedColor: color.withOpacity(0.2),
                    checkmarkColor: color,
                    side: BorderSide(
                        color: _activeStatusFilter == status
                            ? color
                            : Colors.transparent),
                    onSelected: (_) => setState(() =>
                    _activeStatusFilter =
                    _activeStatusFilter == status ? null : status),
                  ),
                );
              }),
            ],
          ),
        ),

        // --- Zoznam ---
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshAssetsFromCloud,
            child: StreamBuilder<List<Asset>>(
              stream: widget.database.watchCompanyAssets(widget.companyCode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = _filterAssets(snapshot.data ?? []);

                if (filtered.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Column(
                          children: [
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
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildAssetCard(filtered[index]),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.12),
          child: Icon(
            asset.isUploaded ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: asset.isUploaded ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(asset.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
        subtitle: Wrap(
          spacing: 8,
          children: [
            Text(asset.status,
                style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.bold)),
            Text('S/N: ${asset.sn}',
                style: const TextStyle(fontSize: 11)),
          ],
        ),
        // NOVÉ: Dlhé podržanie = vymazať
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(
                  children: [
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
                      onPressed: () =>
                          _showTechDetailsSheet(asset.name, asset.techSpecs),
                      icon: const Icon(Icons.list_alt),
                      tooltip: 'Technické parametre',
                    ),
                    // NOVÉ: Tlačidlo na vymazanie
                    IconButton.filledTonal(
                      onPressed: () => _deleteAsset(asset),
                      icon: const Icon(Icons.delete_outline),
                      style: IconButton.styleFrom(
                          foregroundColor: Colors.red),
                      tooltip: 'Vymazať zariadenie',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final history =
                  jsonDecode(asset.history) as List<dynamic>;
                  if (history.isEmpty) return const SizedBox();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${history[0]['date']} – ${history[0]['note']}',
                      style: const TextStyle(
                          fontSize: 12, fontStyle: FontStyle.italic),
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
    return RefreshIndicator(
      onRefresh: _refreshAssetsFromCloud,
      child: StreamBuilder<List<Asset>>(
        stream: widget.database.watchCompanyAssets(widget.companyCode),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final List<Map<String, dynamic>> allHistory = [];
          for (final asset in snapshot.data!) {
            final history = jsonDecode(asset.history) as List<dynamic>;
            for (final entry in history) {
              allHistory.add({
                'assetName': asset.name,
                'date': entry['date'],
                'action': entry['action'],
                'note': entry['note'],
              });
            }
          }
          allHistory.sort((a, b) => b['date'].compareTo(a['date']));

          if (allHistory.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(child: Text('História je prázdna.')),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: allHistory.length,
            itemBuilder: (context, index) {
              final item = allHistory[index];
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.circle,
                            size: 12, color: Colors.blue),
                        Expanded(
                            child: Container(
                                width: 2,
                                color: Colors.blue.withOpacity(0.2))),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['date'],
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            Text(item['assetName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(item['action'],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontSize: 13)),
                            Text(item['note'],
                                style: const TextStyle(fontSize: 13)),
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
}
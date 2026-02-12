import 'dart:convert';
import 'package:bakalarka/database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' as d;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AssetsManagementPage extends StatefulWidget {
  final int initialIndex;
  final String userEmail; // Kto je prihlásený
  final String companyCode; // Firma používateľa
  final dynamic database; // Inštancia AppDatabase

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

class _AssetsManagementPageState extends State<AssetsManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  // --- POMOCNÉ FUNKCIE PRE DB A FIREBASE ---

  Future<void> _saveAssetToDbAndFirebase(AssetsCompanion assetCompanion) async {
    // 1. Uloženie lokálne do Driftu
    final localId = await widget.database.upsertAsset(assetCompanion);

    // 2. Kontrola internetu a synchronizácia na Firebase
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      try {
        // Prevod companion na mapu pre Firebase
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

        // Ak už má firebaseId, aktualizujeme, inak vytvoríme nový dokument
        String? fId = assetCompanion.firebaseId.value;
        if (fId == null) {
          final docRef = await FirebaseFirestore.instance.collection('assets').add(firestoreData);
          fId = docRef.id;
        } else {
          await FirebaseFirestore.instance.collection('assets').doc(fId).update(firestoreData);
        }

        // Označíme v lokálnej DB ako synchronizované
        await widget.database.markAssetAsSynced(localId, fId);
      } catch (e) {
        debugPrint("Chyba pri Firebase synchre: $e");
      }
    }
  }

  Color _getStatusColor(String status) {
    if (status.contains('V prevádzke')) return Colors.green;
    if (status.contains('servis') || status.contains('Porucha')) return Colors.orange;
    if (status.contains('Vyradené')) return Colors.red;
    return Colors.grey;
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.build_circle_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Servis: ${asset.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Aktuálny stav:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: currentStatus,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ['V prevádzke', 'Vyžaduje servis', 'V poruche', 'Odstavené', 'Vyradené']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => currentStatus = val!),
                ),
                const SizedBox(height: 16),
                const Text('Poznámka k servisu:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Napr. Vymenené tesnenie...', border: OutlineInputBorder()),
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Doplniť parametre', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => setModalState(() {
                        newSpecFields.add({'key': TextEditingController(), 'value': TextEditingController()});
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
                        Expanded(child: TextField(controller: field['key'], decoration: const InputDecoration(hintText: 'Názov', isDense: true))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: field['value'], decoration: const InputDecoration(hintText: 'Hodnota', isDense: true))),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setModalState(() => newSpecFields.remove(field)))
                      ],
                    ),
                  )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                    onPressed: () async {
                      // Príprava nových parametrov
                      for (var f in newSpecFields) {
                        if (f['key']!.text.isNotEmpty) currentSpecs[f['key']!.text] = f['value']!.text;
                      }

                      // Príprava histórie
                      List<dynamic> historyList = jsonDecode(asset.history);
                      if (noteController.text.isNotEmpty || currentStatus != asset.status) {
                        historyList.insert(0, {
                          'date': DateTime.now().toString().split(' ')[0],
                          'action': 'Úprava / Servis',
                          'note': noteController.text.isEmpty ? 'Zmena stavu na: $currentStatus' : noteController.text,
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
                      Navigator.pop(context);
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
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Názov (napr. Kotol)')),
            TextField(controller: snCtrl, decoration: const InputDecoration(labelText: 'Sériové číslo')),
            TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'Model')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zrušiť')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || snCtrl.text.isEmpty) return;

              final newAsset = AssetsCompanion.insert(
                name: nameCtrl.text,
                sn: snCtrl.text,
                model: modelCtrl.text,
                status: 'V prevádzke',
                techSpecs: jsonEncode({}),
                history: jsonEncode([{
                  'date': DateTime.now().toString().split(' ')[0],
                  'action': 'Pridanie',
                  'note': 'Zariadenie bolo zaevidované do systému'
                }]),
                userEmail: widget.userEmail,
                companyCode: widget.companyCode,
              );

              await _saveAssetToDbAndFirebase(newAsset);
              Navigator.pop(context);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assetName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (specs.isEmpty) const Center(child: Text('Žiadne parametre'))
            else Flexible(
              child: ListView(
                shrinkWrap: true,
                children: specs.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text(e.key, style: const TextStyle(color: Colors.grey))),
                      Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia majetku'),
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssetsList(),
          _buildGlobalHistory(),
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
    return StreamBuilder<List<Asset>>(
      stream: widget.database.watchCompanyAssets(widget.companyCode),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final assetsList = snapshot.data!;
        // Lokálne zoradenie ak treba
        assetsList.sort((a, b) => _isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

        if (assetsList.isEmpty) return const Center(child: Text('Žiadny majetok vo firme.'));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: assetsList.length,
          itemBuilder: (context, index) {
            final asset = assetsList[index];
            final statusColor = _getStatusColor(asset.status);

            return Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(asset.isUploaded ? Icons.cloud_done : Icons.cloud_off,
                      size: 16, color: asset.isUploaded ? Colors.blue : Colors.orange),
                ),
                title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                subtitle: Wrap(
                  spacing: 8,
                  children: [
                    Text(asset.status, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
                    Text('S/N: ${asset.sn}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
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
                                style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              onPressed: () => _showTechDetailsSheet(asset.name, asset.techSpecs),
                              icon: const Icon(Icons.list_alt),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Posledná aktivita z JSON histórie
                        Builder(builder: (context) {
                          List history = jsonDecode(asset.history);
                          if (history.isEmpty) return const SizedBox();
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "${history[0]['date']} - ${history[0]['note']}",
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          );
                        }),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlobalHistory() {
    return StreamBuilder<List<Asset>>(
      stream: widget.database.watchCompanyAssets(widget.companyCode),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        // Vytiahnutie všetkých záznamov z histórie zo všetkých zariadení
        List<Map<String, dynamic>> allHistory = [];
        for (var asset in snapshot.data!) {
          List history = jsonDecode(asset.history);
          for (var entry in history) {
            allHistory.add({
              'assetName': asset.name,
              'date': entry['date'],
              'action': entry['action'],
              'note': entry['note'],
            });
          }
        }
        allHistory.sort((a, b) => b['date'].compareTo(a['date']));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allHistory.length,
          itemBuilder: (context, index) {
            final item = allHistory[index];
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, size: 12, color: Colors.blue),
                      Expanded(child: Container(width: 2, color: Colors.blue.withOpacity(0.2))),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(item['assetName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(item['action'], style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13)),
                          Text(item['note'], style: const TextStyle(fontSize: 13)),
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
    );
  }
}
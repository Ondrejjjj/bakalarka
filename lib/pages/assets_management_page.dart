import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AssetsManagementPage extends StatefulWidget {
  final int initialIndex;
  const AssetsManagementPage({super.key, this.initialIndex = 0});

  @override
  State<AssetsManagementPage> createState() => _AssetsManagementPageState();
}

class _AssetsManagementPageState extends State<AssetsManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAscending = true;

  // Rozšírená dátová štruktúra o históriu a poznámky
  final List<Map<String, dynamic>> _assets = [
    {
      'name': 'Plynový kotol Buderus',
      'sn': 'SN-987654321',
      'model': 'Logamax Plus',
      'url': 'https://www.buderus.sk',
      'status': 'V prevádzke',
      'image': null,
      'tech_specs': {
        'Výkon': '24 kW',
        'Rok výroby': '2022',
        'Pracovný tlak': '1.5 bar',
        'Typ plynu': 'Zemný plyn'
      },
      'history': [
        {'date': '2024-01-10', 'action': 'Inštalácia', 'note': 'Prvé spustenie do prevádzky'}
      ]
    },
    {
      'name': 'Tepelné čerpadlo Viessmann',
      'sn': 'SN-11223344',
      'model': 'Vitocal 200-S',
      'url': 'https://www.viessmann.sk',
      'status': 'Vyžaduje servis',
      'image': null,
      'tech_specs': {
        'Výkon': '12 kW',
        'Rok inštalácie': '2023',
        'Chladivo': 'R32'
      },
      'history': [
        {'date': '2024-02-12', 'action': 'Porucha', 'note': 'Nízky tlak v okruhu'}
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _sortAssets();
  }

  void _sortAssets() {
    setState(() {
      _assets.sort((a, b) => _isAscending
          ? (a['name'] ?? "").compareTo(b['name'] ?? "")
          : (b['name'] ?? "").compareTo(a['name'] ?? ""));
    });
  }

  Color _getStatusColor(String status) {
    if (status.contains('V prevádzke')) return Colors.green;
    if (status.contains('servis') || status.contains('Porucha')) return Colors.orange;
    if (status.contains('Vyradené')) return Colors.red;
    return Colors.grey;
  }

  void _showEditAssetDialog(int index) {
    final asset = _assets[index];
    final TextEditingController noteController = TextEditingController();

    String currentStatus = asset['status'];
    Map<String, dynamic> currentSpecs = Map.from(asset['tech_specs'] ?? {});
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
                    // OPRAVA: Expanded zabráni overflow pri dlhom názve v dialógu
                    Expanded(child: Text('Servis: ${asset['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Aktuálny stav:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true, // OPRAVA: Aby text v menu nepretiekol
                  value: currentStatus,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ['V prevádzke', 'Vyžaduje servis', 'V poruche', 'Odstavené', 'Vyradené']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => currentStatus = val!),
                ),

                const SizedBox(height: 16),

                const Text('Poznámka k servisu / Dôvod zmeny:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Napr. Vymenené tesnenie, dopustená voda...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // OPRAVA: Row obalený do Wrap alebo Flexible tlačidlá
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Otvarám kameru... (Demo)')));
                        },
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Pridať fotku', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text('Galéria', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
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
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setModalState(() => newSpecFields.remove(field)),
                        )
                      ],
                    ),
                  )),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _assets[index]['status'] = currentStatus;
                        for (var f in newSpecFields) {
                          if (f['key']!.text.isNotEmpty) {
                            currentSpecs[f['key']!.text] = f['value']!.text;
                          }
                        }
                        _assets[index]['tech_specs'] = currentSpecs;

                        if (noteController.text.isNotEmpty || currentStatus != asset['status']) {
                          List<dynamic> history = List.from(_assets[index]['history'] ?? []);
                          history.insert(0, {
                            'date': DateTime.now().toString().split(' ')[0],
                            'action': 'Úprava / Servis',
                            'note': noteController.text.isEmpty ? 'Zmena stavu na: $currentStatus' : noteController.text,
                          });
                          _assets[index]['history'] = history;
                        }
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zmeny boli uložené')));
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

  void _showTechDetailsSheet(String assetName, dynamic specs) {
    final Map<String, dynamic> safeSpecs = (specs as Map<String, dynamic>?) ?? {};
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
            if (safeSpecs.isEmpty)
              const Center(child: Text('Žiadne dáta'))
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: safeSpecs.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // OPRAVA: Flexible pri kľúčoch parametrov
                        Flexible(child: Text(e.key, style: const TextStyle(color: Colors.grey))),
                        const SizedBox(width: 10),
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

  void _showAddAssetDialog(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pridávanie zariadenia')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia majetku'),
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
            onPressed: () {
              _isAscending = !_isAscending;
              _sortAssets();
            },
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
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final statusColor = _getStatusColor(asset['status'] ?? '');

        return Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.settings_input_component, color: statusColor),
            ),
            // OPRAVA: Flexible/Overflow ošetrenie v titulku
            title: Text(
              asset['name'] ?? 'Neznáme',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Wrap( // OPRAVA: Wrap namiesto Row zabráni overflow pri dlhom S/N
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(asset['status'] ?? '-', style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
                ),
                Text('S/N: ${asset['sn'] ?? '-'}', style: const TextStyle(fontSize: 11)),
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
                            onPressed: () => _showEditAssetDialog(index),
                            icon: const Icon(Icons.build, size: 16),
                            label: const Text('Servis / Úprava', style: TextStyle(fontSize: 13)),
                            style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () => _showTechDetailsSheet(asset['name'], asset['tech_specs']),
                          icon: const Icon(Icons.list_alt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (asset['history'] != null && (asset['history'] as List).isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Posledná aktivita:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              "${(asset['history'][0]['date'])} - ${(asset['history'][0]['note'])}",
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final urlStr = asset['url'];
                          if (urlStr != null) await launchUrl(Uri.parse(urlStr), mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.open_in_browser, size: 16),
                        label: const Text('Dokumentácia', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlobalHistory() {
    List<Map<String, dynamic>> allHistory = [];
    for (var asset in _assets) {
      if (asset['history'] != null) {
        for (var entry in asset['history']) {
          allHistory.add({
            'assetName': asset['name'],
            'date': entry['date'],
            'action': entry['action'],
            'note': entry['note'],
          });
        }
      }
    }
    allHistory.sort((a, b) => b['date'].compareTo(a['date']));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allHistory.length,
      itemBuilder: (context, index) {
        final item = allHistory[index];
        return IntrinsicHeight( // OPRAVA: Pre správne vykreslenie čiary
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
                      Text(item['assetName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(item['action'], style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(item['note'], style: const TextStyle(color: Colors.black87, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
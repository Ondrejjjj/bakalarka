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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia majetku'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.precision_manufacturing_outlined), text: 'Zariadenia'),
            Tab(icon: Icon(Icons.plumbing_outlined), text: 'História kontrol'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tu sa bude neskôr volať dialog na pridanie majetku
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- 1. ZOZNAM ZARIADENÍ ---
  Widget _buildAssetsList() {
    final dummyAssets = [
      {
        'name': 'Plynový kotol Buderus',
        'sn': 'SN-987654321',
        'model': 'Logamax Plus',
        'url': 'https://www.buderus.sk',
        'status': 'V prevádzke'
      },
      {
        'name': 'Tepelné čerpadlo Viessmann',
        'sn': 'SN-11223344',
        'model': 'Vitocal 200-S',
        'url': 'https://www.viessmann.sk',
        'status': 'Vyžaduje servis'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dummyAssets.length,
      itemBuilder: (context, index) {
        final asset = dummyAssets[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            // Material 3 úprava: odstránenie deliacich čiar pri rozbalení
            shape: const Border(),
            collapsedShape: const Border(),
            leading: Icon(Icons.settings_input_component, color: Theme.of(context).colorScheme.primary),
            title: Text(asset['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('S/N: ${asset['sn']}'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildDetailRow('Model:', asset['model']!),
                    _buildDetailRow('Stav:', asset['status']!,
                        valueColor: asset['status']!.contains('Vyžaduje') ? Colors.orange : Colors.green),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Obchodné info:', style: TextStyle(fontWeight: FontWeight.w500)),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            final url = Uri.parse(asset['url']!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_browser, size: 18),
                          label: const Text('Web výrobcu'),
                        ),
                      ],
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

  // --- 2. GLOBÁLNA HISTÓRIA KONTROL ---
  Widget _buildGlobalHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 4,
      itemBuilder: (context, index) {
        // Oprava: Používame Card.outlined pre čistý Material 3 vzhľad bez chyby
        return Card.outlined(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.assignment_turned_in_outlined, color: Colors.blue, size: 20),
            ),
            title: Text(index % 2 == 0 ? 'Ročná revízia' : 'Oprava poruchy',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Zariadenie: Kotol Buderus\nTechnik: peter@firma.sk'),
            trailing: Text('10.02.2026', style: Theme.of(context).textTheme.labelSmall),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // Pomocná funkcia pre krajšie riadky v detaile
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: valueColor, fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
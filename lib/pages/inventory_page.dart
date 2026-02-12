import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skladové hospodárstvo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Stav zásob'),
            Tab(icon: Icon(Icons.history), text: 'Pohyby'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockList(),
          _buildMovementHistory(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMovementDialog(context),
        label: const Text('Príjem / Výdaj'),
        icon: const Icon(Icons.add_chart),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }

  // 1. ZOZNAM AKTUÁLNYCH ZÁSOB
  Widget _buildStockList() {
    // Tu bude neskôr StreamBuilder z Drift databázy
    final dummyInventory = [
      {'name': 'Ventil 1/2"', 'sku': 'V-001', 'qty': 12, 'unit': 'ks'},
      {'name': 'Tesnenie gumové', 'sku': 'T-102', 'qty': 50, 'unit': 'ks'},
      {'name': 'Medená rúrka 15mm', 'sku': 'R-M15', 'qty': 5.5, 'unit': 'm'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dummyInventory.length,
      itemBuilder: (context, index) {
        final item = dummyInventory[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
            title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Kód: ${item['sku']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item['qty']} ${item['unit']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text('na sklade', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. HISTÓRIA POHYBOV
  Widget _buildMovementHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        bool isInput = index % 2 == 0;
        return ListTile(
          leading: Icon(
            isInput ? Icons.arrow_downward : Icons.arrow_upward,
            color: isInput ? Colors.green : Colors.red,
          ),
          title: Text(isInput ? 'Príjem tovaru' : 'Výdaj na servis'),
          subtitle: const Text('12. 02. 2026 - Ventil 1/2"'),
          trailing: Text(
            isInput ? '+5 ks' : '-1 ks',
            style: TextStyle(color: isInput ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  // 3. DIALÓG PRE PRÍJEM A VÝDAJ
  void _showMovementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nový skladový pohyb'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Typ pohybu'),
              items: const [
                DropdownMenuItem(value: 'IN', child: Text('Príjem (Naskladnenie)')),
                DropdownMenuItem(value: 'OUT', child: Text('Výdaj (Spotreba)')),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Súčiastka', prefixIcon: Icon(Icons.search)),
            ),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Množstvo', suffixText: 'ks'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zrušiť')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Uložiť')),
        ],
      ),
    );
  }
}
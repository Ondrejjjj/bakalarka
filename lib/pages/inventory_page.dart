import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Dummy dáta skladu (neskôr z Drift DB)
  // Pridal som 'ean' ako unikátne číslo
  final List<Map<String, dynamic>> _inventory = [
    {'name': 'Ventil Guľový 1/2"', 'sku': 'V-001', 'ean': '100123456', 'qty': 12.0, 'unit': 'ks'},
    {'name': 'Tesnenie gumové', 'sku': 'T-102', 'ean': '100987654', 'qty': 50.0, 'unit': 'ks'},
    {'name': 'Medená rúrka 15mm', 'sku': 'R-M15', 'ean': '200112233', 'qty': 5.5, 'unit': 'm'},
    {'name': 'Tepelná pasta', 'sku': 'CHE-01', 'ean': '300555666', 'qty': 2.0, 'unit': 'tuba'},
  ];

  List<Map<String, dynamic>> _filteredInventory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredInventory = List.from(_inventory); // Na začiatku zobrazíme všetko

    // Listener na vyhľadávanie
    _searchController.addListener(_filterInventory);
  }

  void _filterInventory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredInventory = _inventory.where((item) {
        final name = item['name'].toString().toLowerCase();
        final sku = item['sku'].toString().toLowerCase();
        final ean = item['ean'].toString().toLowerCase(); // Hľadáme aj podľa unikátneho ID
        return name.contains(query) || sku.contains(query) || ean.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- DIALÓG PRE POHYB (PRÍJEM / VÝDAJ) ---
  void _showStockMovementSheet(BuildContext context, {Map<String, dynamic>? preselectedItem}) {
    // Premenné pre stav formulára
    bool isIncome = false; // Defaultne výdaj (častejšia akcia technika)
    String? selectedSku = preselectedItem?['sku'];
    final qtyController = TextEditingController();

    // Dynamické polia (napr. Číslo zákazky, Poznámka)
    List<Map<String, TextEditingController>> dynamicFields = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rukoväť na potiahnutie
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),

                    // Nadpis
                    Text('Skladový pohyb', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // 1. Prepínač PRÍJEM / VÝDAJ
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Výdaj (Spotreba)')),
                            selected: !isIncome,
                            onSelected: (val) => setModalState(() => isIncome = !val),
                            selectedColor: Colors.red.withOpacity(0.2),
                            labelStyle: TextStyle(color: !isIncome ? Colors.red[900] : Colors.grey, fontWeight: FontWeight.bold),
                            avatar: !isIncome ? const Icon(Icons.arrow_upward, color: Colors.red) : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Príjem (Nákup)')),
                            selected: isIncome,
                            onSelected: (val) => setModalState(() => isIncome = val),
                            selectedColor: Colors.green.withOpacity(0.2),
                            labelStyle: TextStyle(color: isIncome ? Colors.green[900] : Colors.grey, fontWeight: FontWeight.bold),
                            avatar: isIncome ? const Icon(Icons.arrow_downward, color: Colors.green) : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Výber položky (Ak nie je predvybratá)
                    DropdownButtonFormField<String>(
                      value: selectedSku,
                      decoration: const InputDecoration(labelText: 'Položka skladu', border: OutlineInputBorder()),
                      items: _inventory.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['sku'],
                          child: Text('${item['name']} (${item['qty']} ${item['unit']})'),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedSku = val),
                    ),
                    const SizedBox(height: 12),

                    // 3. Množstvo
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Množstvo',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.numbers),
                      ),
                    ),

                    const Divider(height: 40),

                    // 4. Dynamické polia (napr. na akú zákazku to išlo)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Doplnkové údaje', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () => setModalState(() {
                            dynamicFields.add({'key': TextEditingController(), 'value': TextEditingController()});
                          }),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Pridať pole'),
                        ),
                      ],
                    ),

                    // Zoznam dynamických polí
                    ...dynamicFields.map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: TextField(controller: field['key'], decoration: const InputDecoration(hintText: 'Názov (napr. Zákazka)'))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: field['value'], decoration: const InputDecoration(hintText: 'Hodnota (napr. #2024/01)'))),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => setModalState(() => dynamicFields.remove(field)),
                          )
                        ],
                      ),
                    )),

                    const SizedBox(height: 24),

                    // Tlačidlo potvrdiť
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // TU BUDE LOGIKA ULOŽENIA DO DB
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isIncome ? 'Zásoby boli navýšené' : 'Materiál bol vydaný zo skladu')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isIncome ? Colors.green : Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isIncome ? 'POTVRDIŤ PRÍJEM' : 'POTVRDIŤ VÝDAJ'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skladové hospodárstvo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Stav zásob'),
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
      // Hlavné FAB tlačidlo pre všeobecný príjem/výdaj
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStockMovementSheet(context),
        label: const Text('Nový pohyb'),
        icon: const Icon(Icons.swap_vert),
      ),
    );
  }

  // 1. ZOZNAM ZÁSOB S VYHĽADÁVANÍM
  Widget _buildStockList() {
    return Column(
      children: [
        // Vyhľadávací panel
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Hľadať podľa názvu, ID alebo EAN...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // Zoznam kariet
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filteredInventory.length,
            itemBuilder: (context, index) {
              final item = _filteredInventory[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  // Kliknutím na kartu sa otvorí dialóg predvyplnený pre túto položku
                  onTap: () => _showStockMovementSheet(context, preselectedItem: item),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.qr_code, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                                    child: Text('ID: ${item['ean']}', style: const TextStyle(fontSize: 12, fontFamily: 'Monospace')),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item['sku'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item['qty']} ${item['unit']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Text('na sklade', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. HISTÓRIA POHYBOV (Len vizuál)
  Widget _buildMovementHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        bool isInput = index % 2 == 0;
        return Card(
          elevation: 0,
          color: isInput ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isInput ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              child: Icon(isInput ? Icons.arrow_downward : Icons.arrow_upward, color: isInput ? Colors.green[800] : Colors.red[800], size: 20),
            ),
            title: Text(isInput ? 'Naskladnenie' : 'Výdaj - Zákazka #2024'),
            subtitle: const Text('Ventil Guľový 1/2"'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isInput ? '+ 50 ks' : '- 2 ks',
                  style: TextStyle(
                      color: isInput ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),
                Text('12.02. 14:30', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}
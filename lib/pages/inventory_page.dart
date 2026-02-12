import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as d;
import 'package:provider/provider.dart';
import 'package:bakalarka/database.dart';

class InventoryPage extends StatefulWidget {
  final String userEmail;
  final String companyCode;

  const InventoryPage({
    super.key,
    required this.userEmail,
    required this.companyCode,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _itemSearchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }

  // --- Logika ukladania pohybu ---
  Future<void> _handleMovementSave({
    required AppDatabase db,
    required InventoryData item,
    required bool isIncome,
    required double amount,
    required Map<String, String> extraData,
    required String userEmail,
    required String companyCode,
  }) async {
    final movementQty = isIncome ? amount : -amount;

    final movementCompanion = StockMovementsCompanion.insert(
      inventoryId: item.id,
      itemName: item.name,
      changeQty: movementQty,
      type: isIncome ? 'income' : 'outcome',
      extraData: d.Value(jsonEncode(extraData)),
      userEmail: userEmail,
      companyCode: companyCode,
      createdAt: d.Value(DateTime.now()),
    );

    await db.registerMovement(item, movementCompanion);

    final updatedItem = item.copyWith(qty: item.qty + movementQty);

    final movementData = StockMovement(
      id: 0,
      inventoryId: item.id,
      itemName: item.name,
      changeQty: movementQty,
      type: isIncome ? 'income' : 'outcome',
      extraData: jsonEncode(extraData),
      userEmail: userEmail,
      companyCode: companyCode,
      createdAt: DateTime.now(),
      isUploaded: false,
    );

    db.syncMovementToFirebase(movementData, updatedItem);
  }

  // --- UI Dialóg pre pohyb ---
  void _showStockMovementSheet(BuildContext context, {InventoryData? preselectedItem, required String userEmail, required String companyCode}) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    bool isIncome = preselectedItem == null ? true : false;
    InventoryData? selectedItem = preselectedItem;
    final qtyController = TextEditingController();
    final eanController = TextEditingController();
    final skuController = TextEditingController();

    _itemSearchController.text = preselectedItem?.name ?? '';
    List<Map<String, TextEditingController>> dynamicFields = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Skladový pohyb', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Výdaj')),
                        selected: !isIncome,
                        onSelected: (val) => setModalState(() => isIncome = !val),
                        selectedColor: Colors.red.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Príjem')),
                        selected: isIncome,
                        onSelected: (val) => setModalState(() => isIncome = val),
                        selectedColor: Colors.green.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                StreamBuilder<List<InventoryData>>(
                  stream: db.watchCompanyInventory(companyCode),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    return Autocomplete<InventoryData>(
                      displayStringForOption: (InventoryData option) => option.name,
                      initialValue: TextEditingValue(text: _itemSearchController.text),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') return items;
                        return items.where((i) => i.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (InventoryData selection) {
                        setModalState(() {
                          selectedItem = selection;
                          _itemSearchController.text = selection.name;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        if (_itemSearchController.text != controller.text && _itemSearchController.text.isNotEmpty && controller.text.isEmpty) {
                          controller.text = _itemSearchController.text;
                        }
                        controller.addListener(() {
                          _itemSearchController.text = controller.text;
                        });
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Názov položky (vyber alebo napíš novú)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        );
                      },
                    );
                  },
                ),

                if (selectedItem == null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: eanController, decoration: const InputDecoration(labelText: 'EAN', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: skuController, decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder()))),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Množstvo', border: OutlineInputBorder(), suffixIcon: Icon(Icons.numbers)),
                ),

                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Doplnkové údaje', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => setModalState(() => dynamicFields.add({'key': TextEditingController(), 'value': TextEditingController()})),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Pridať'),
                    ),
                  ],
                ),
                ...dynamicFields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: field['key'], decoration: const InputDecoration(hintText: 'Názov'))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: field['value'], decoration: const InputDecoration(hintText: 'Hodnota'))),
                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setModalState(() => dynamicFields.remove(field))),
                    ],
                  ),
                )),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final itemName = _itemSearchController.text.trim();
                      final rawQty = qtyController.text;
                      final amount = double.tryParse(rawQty) ?? 0.0;
                      final eanVal = eanController.text.trim().isEmpty ? "-" : eanController.text.trim();
                      final skuVal = skuController.text.trim().isEmpty ? "-" : skuController.text.trim();

                      if (itemName.isEmpty || amount <= 0) return;

                      InventoryData itemToUse;
                      if (selectedItem == null) {
                        final existingItems = await db.watchCompanyInventory(companyCode).first;
                        final match = existingItems.where((i) => i.name.toLowerCase() == itemName.toLowerCase()).toList();

                        if (match.isNotEmpty) {
                          itemToUse = match.first;
                        } else {
                          final newId = await db.into(db.inventory).insert(
                            InventoryCompanion.insert(
                              name: itemName,
                              qty: d.Value(0.0),
                              unit: 'ks',
                              ean: eanVal,
                              sku: skuVal,
                              companyCode: companyCode,
                              userEmail: userEmail,
                            ),
                          );
                          itemToUse = await (db.select(db.inventory)..where((t) => t.id.equals(newId))).getSingle();
                        }
                      } else {
                        itemToUse = selectedItem!;
                      }

                      Map<String, String> extra = {};
                      for (var f in dynamicFields) {
                        if (f['key']!.text.isNotEmpty) extra[f['key']!.text] = f['value']!.text;
                      }

                      await _handleMovementSave(
                        db: db,
                        item: itemToUse,
                        isIncome: isIncome,
                        amount: amount,
                        extraData: extra,
                        userEmail: userEmail,
                        companyCode: companyCode,
                      );

                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: isIncome ? Colors.green : Colors.red, foregroundColor: Colors.white),
                    child: Text(isIncome ? 'POTVRDIŤ PRÍJEM' : 'POTVRDIŤ VÝDAJ'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Používame reálne dáta z widgetu, nie mocky
    final String currentEmail = widget.userEmail;
    final String currentCompany = widget.companyCode;

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
          _buildStockList(currentCompany, currentEmail),
          _buildMovementHistory(currentCompany),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStockMovementSheet(context, userEmail: currentEmail, companyCode: currentCompany),
        label: const Text('Nový pohyb'),
        icon: const Icon(Icons.swap_vert),
      ),
    );
  }

  Widget _buildStockList(String companyCode, String userEmail) {
    final db = Provider.of<AppDatabase>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Hľadať v sklade...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<InventoryData>>(
            stream: db.watchCompanyInventory(companyCode),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Sklad je prázdny.'));

              final filtered = snapshot.data!.where((item) {
                return item.name.toLowerCase().contains(_searchQuery) ||
                    item.ean.toLowerCase().contains(_searchQuery) ||
                    item.sku.toLowerCase().contains(_searchQuery);
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _showStockMovementSheet(context, preselectedItem: item, userEmail: userEmail, companyCode: companyCode),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory, color: Colors.blue, size: 30),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('ID: ${item.ean} | SKU: ${item.sku}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text('${item.qty} ${item.unit}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovementHistory(String companyCode) {
    final db = Provider.of<AppDatabase>(context);
    return StreamBuilder<List<StockMovement>>(
      stream: db.watchMovementHistory(companyCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Žiadna história pohybov.'));

        final movements = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final move = movements[index];
            final isIncome = move.type == 'income';

            return Card(
              elevation: 0,
              color: isIncome ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(isIncome ? Icons.add_circle : Icons.remove_circle, color: isIncome ? Colors.green : Colors.red),
                title: Text(move.itemName),
                subtitle: Text('${move.userEmail}\n${move.createdAt.day}.${move.createdAt.month}. ${move.createdAt.hour}:${move.createdAt.minute.toString().padLeft(2, '0')}'),
                isThreeLine: true,
                trailing: Text(
                  '${isIncome ? "+" : ""}${move.changeQty}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green[800] : Colors.red[800], fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
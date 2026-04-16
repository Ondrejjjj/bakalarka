import 'dart:convert';
import 'package:bakalarka/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as d;
import 'package:provider/provider.dart';
import 'package:bakalarka/database.dart';
import 'package:bakalarka/services/sync_service.dart'; // PRIDANÉ: Import tvojho SyncService

class InventoryPage extends StatefulWidget {
  final String userEmail;
  final String companyCode;
  final int initialTab;

  const InventoryPage({
    super.key,
    required this.userEmail,
    required this.companyCode,
    this.initialTab = 0,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _itemSearchController = TextEditingController();
  String _searchQuery = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    // Listener len pre search
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDataFromCloud();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }


  Future<void> _refreshDataFromCloud() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final syncService = SyncService(db);
      await syncService.restoreAllUserData();
    } catch (e) {

    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
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
                Text(S.of(context).skladovyPohyb, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label:Center(child: Text(S.of(context).vydaj)),
                        selected: !isIncome,
                        onSelected: (val) => setModalState(() => isIncome = !val),
                        selectedColor: Colors.red.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label:Center(child: Text(S.of(context).prijem)),
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
                          decoration: InputDecoration(
                            labelText: S.of(context).nazovPolozky,
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
                  decoration: InputDecoration(labelText: S.of(context).mnozstvo, border: OutlineInputBorder(), suffixIcon: Icon(Icons.numbers)),
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).doplnkoveUdaje, style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => setModalState(() => dynamicFields.add({'key': TextEditingController(), 'value': TextEditingController()})),
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(S.of(context).pridatB),
                    ),
                  ],
                ),
                ...dynamicFields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: field['key'], decoration: InputDecoration(hintText: S.of(context).nazovHint))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: field['value'], decoration: InputDecoration(hintText: S.of(context).hodnotaHint))),
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
                    child: Text(isIncome ? S.of(context).potvrditPrijem : S.of(context).potvrditVydaj),
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
    final String currentEmail = widget.userEmail;
    final String currentCompany = widget.companyCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).skladH),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: S.of(context).statusZ),
            Tab(icon: Icon(Icons.history), text: S.of(context).pohybyT),
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
                _buildStockList(currentCompany, currentEmail),
                _buildMovementHistory(currentCompany),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStockMovementSheet(context, userEmail: currentEmail, companyCode: currentCompany),
        label: Text(S.of(context).novyP),
        icon: const Icon(Icons.swap_vert),
      ),
    );
  }

  Widget _buildStockList(String companyCode, String userEmail) {
    final db = Provider.of<AppDatabase>(context);

    return RefreshIndicator(
      onRefresh: _refreshDataFromCloud,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.of(context).Hladanie,
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
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return ListView(
                    children: [SizedBox(height: 200), Center(child: Text(S.of(context).skladJePrazdny))],
                  );
                }

                final filtered = snapshot.data!.where((item) {
                  return item.name.toLowerCase().contains(_searchQuery) ||
                      item.ean.toLowerCase().contains(_searchQuery) ||
                      item.sku.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildMovementHistory(String companyCode) {
    final db = Provider.of<AppDatabase>(context);
    return StreamBuilder<List<StockMovement>>(
      stream: db.watchMovementHistory(companyCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(S.of(context).ziadnaHistoria));

        final movements = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _refreshDataFromCloud,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: movements.length,
            itemBuilder: (context, index) {
              final move = movements[index];
              final isIncome = move.type == 'income';

              // --- DEKÓDOVANIE EXTRA DÁT ---
              Map<String, dynamic> extra = {};
              try {
                if (move.extraData != null && move.extraData!.isNotEmpty) {
                  extra = jsonDecode(move.extraData!);
                }
              } catch (e) {
              }

              return Card(
                elevation: 0,
                color: isIncome ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                ),
                child: ExpansionTile(
                  leading: Icon(
                    isIncome ? Icons.add_circle : Icons.remove_circle,
                    color: isIncome ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  title: Text(move.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${move.userEmail}\n${move.createdAt.day}.${move.createdAt.month}. ${move.createdAt.hour}:${move.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    '${isIncome ? "+" : ""}${move.changeQty}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green[800] : Colors.red[800],
                        fontSize: 18
                    ),
                  ),
                  children: [
                    if (extra.isNotEmpty) ...[
                      const Divider(indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).doplnkoveUdaje, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            ...extra.entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text("${e.key}: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Expanded(child: Text("${e.value}", style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      )
                    ] else ...[
                      Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(S.of(context).ziadneDoplnkove, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      )
                    ]
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
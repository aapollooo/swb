import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class StaffInventoryPage extends StatefulWidget {
  const StaffInventoryPage({super.key});

  @override
  State<StaffInventoryPage> createState() => _StaffInventoryPageState();
}

class _StaffInventoryPageState extends State<StaffInventoryPage> {
  bool _isLoading = true;
  List<InventoryItem> _inventory = [];
  String? _selectedCategory;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    try {
      String url = "http://192.168.18.7/swb_api/get_inventory.php";
      if (_showLowStockOnly) {
        url += "?low_stock=1";
      } else if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        url += "?category=$_selectedCategory";
      }

      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> list = data['inventory'] as List<dynamic>;
        final items = list
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _inventory = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _inventory = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _inventory = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load inventory: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventory,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Show Low Stock Only'),
                    value: _showLowStockOnly,
                    onChanged: (value) {
                      setState(() {
                        _showLowStockOnly = value ?? false;
                      });
                      _loadInventory();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _inventory.isEmpty
                    ? const Center(
                        child: Text('No inventory items found'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInventory,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _inventory.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _inventory[index];
                            return Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.itemName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (item.needsReorder)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'LOW STOCK',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (item.category != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Category: ${item.category}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                    if (item.description != null &&
                                        item.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description!,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Available: ${item.quantityAvailable}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (item.quantityReserved > 0)
                                              Text(
                                                'Reserved: ${item.quantityReserved}',
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                ),
                                              ),
                                          ],
                                        ),
                                        Text(
                                          '₱${item.unitPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.supplier != null &&
                                        item.supplier!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Supplier: ${item.supplier}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add inventory page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add inventory feature coming soon'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}

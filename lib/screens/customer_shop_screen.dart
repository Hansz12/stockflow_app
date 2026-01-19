// screens/customer_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; 
import 'package:intl/intl.dart';
import '../main.dart';
import '../models.dart';

class CustomerShopScreen extends StatefulWidget {
  final bool isSupplier;
  final ValueChanged<bool> onToggleRole;
  const CustomerShopScreen({super.key, required this.isSupplier, required this.onToggleRole});

  @override
  State<CustomerShopScreen> createState() => _CustomerShopScreenState();
}

class _CustomerShopScreenState extends State<CustomerShopScreen> {
  final Map<String, int> _cart = {};
  final NumberFormat _currency = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

  void _updateCart(InventoryItem item, int quantity) {
    setState(() {
      if (quantity > 0) {
        _cart[item.id] = quantity;
      } else {
        _cart.remove(item.id);
      }
    });
  }

  // --- SCANNER UI ---
  void _openScanner(GlobalAppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 600,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: const Text('Scan Product', style: TextStyle(color: Colors.white)),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _handleScannedCode(barcode.rawValue!, state);
                          return; // Stop after first match
                        }
                      }
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Point camera at barcode",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _handleScannedCode(String code, GlobalAppState state) {
    try {
      // Logic to find item
      final item = state.inventory.firstWhere((i) => i.barcode == code);
      final currentQty = _cart[item.id] ?? 0;
      
      if (currentQty < item.stock) {
        _updateCart(item, currentQty + 1);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added: ${item.name}'), 
            backgroundColor: kPrimaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Out of Stock!'), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barcode $code not found.'), 
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _placeOrder(GlobalAppState state) {
    if (_cart.isEmpty) return;

    final List<OrderItem> items = [];
    double totalValue = 0;

    for (final entry in _cart.entries) {
      final itemId = entry.key;
      final quantity = entry.value;
      final itemIndex = state.inventory.indexWhere((i) => i.id == itemId);
      
      if (itemIndex != -1) {
        final item = state.inventory[itemIndex];
        items.add(OrderItem(
          itemId: item.id,
          itemName: item.name,
          quantity: quantity,
          price: item.price,
        ));
        totalValue += (item.price * quantity);
        state.updateStock(itemId, -quantity.toDouble());
      }
    }

    final newOrder = Order(
      id: 'POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      customerName: 'Walk-in Customer',
      date: DateTime.now(),
      status: OrderStatus.delivered, 
      items: items,
      totalAmount: totalValue,
    );

    state.addOrder(newOrder);

    setState(() {
      _cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale Recorded! Stock Updated.'), backgroundColor: kPrimaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GlobalAppState.of(context);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Mode (POS)'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, size: 28),
            onPressed: () => _openScanner(state),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => widget.onToggleRole(true),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.inventory.length,
        itemBuilder: (context, index) {
          final item = state.inventory[index];
          final qty = _cart[item.id] ?? 0;
          return Card(
            elevation: 2,
            // ignore: deprecated_member_use
            shadowColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Icon(Icons.qr_code, color: Colors.orange.shade400, size: 24),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${item.barcode} • ${_currency.format(item.price)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        if (item.stock < item.lowStockThreshold)
                           Text('Low Stock: ${item.stock.toInt()}', style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: qty > 0 ? () => _updateCart(item, qty - 1) : null,
                        ),
                        Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18, color: Colors.orange),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: qty < item.stock ? () => _updateCart(item, qty + 1) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _cart.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () => _placeOrder(state),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.check),
        label: Text('Checkout (${_cart.length})'),
      ) : null,
    );
  }
}
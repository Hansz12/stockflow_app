// views/inventory_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../main.dart';

class InventoryView extends StatelessWidget {
  final List<InventoryItem> inventory;

  const InventoryView({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    final state = GlobalAppState.of(context);
    
    return ListView.builder(
      itemCount: inventory.length,
      itemBuilder: (context, index) {
        return _InventoryCard(item: inventory[index], onUpdateStock: state.updateStock);
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final Function(String, double) onUpdateStock;

  const _InventoryCard({required this.item, required this.onUpdateStock});

  @override
  Widget build(BuildContext context) {
    // Determine status
    final bool isLow = item.stock <= item.lowStockThreshold;
    final double stockPercent = (item.stock / 100).clamp(0.0, 1.0); // Mock 100 as max
    
    final Color statusColor = isLow ? Colors.red : kPrimaryColor;
    final String statusText = isLow ? 'Low Stock' : 'In Stock';
    final currency = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(currency.format(item.price), style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(statusText, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  Row(
                    children: [
                      Text('${item.stock.toInt()} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: stockPercent,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
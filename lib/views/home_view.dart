// views/home_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../main.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GlobalAppState.of(context);
    final totalRevenue = state.orders.fold(0.0, (sum, item) => sum + item.totalAmount);
    final pendingCount = state.orders.where((o) => o.status == OrderStatus.pending).length;
    final lowStockCount = state.inventory.where((i) => i.stock <= i.lowStockThreshold).length;
    final currency = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildCard(Icons.attach_money, 'Revenue', currency.format(totalRevenue), Colors.green),
              _buildCard(Icons.shopping_bag_outlined, 'Pending', '$pendingCount', Colors.orange),
              _buildCard(Icons.local_shipping_outlined, 'Active', '12', Colors.blue),
              _buildCard(Icons.warning_amber_rounded, 'Low Stock', '$lowStockCount', Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(16),
               // ignore: deprecated_member_use
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
             ),
             child: ListTile(
               contentPadding: const EdgeInsets.all(16),
               leading: Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                 child: const Icon(Icons.notifications_active, color: Colors.orange),
               ),
               title: Text('$lowStockCount items are low on stock', style: const TextStyle(fontWeight: FontWeight.bold)),
               subtitle: const Text('Restock recommended immediately.'),
               trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))],
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            // ignore: deprecated_member_use
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87)),
        ],
      ),
    );
  }
}
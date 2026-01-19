// views/orders_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../main.dart';

class OrdersView extends StatelessWidget {
  final String activeTab;
  final List<Order> orders;

  const OrdersView({super.key, required this.activeTab, required this.orders});

  @override
  Widget build(BuildContext context) {
    final filteredOrders = activeTab.isEmpty 
        ? orders 
        : orders.where((o) => o.status.name == activeTab).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text('No $activeTab orders', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    
    final state = GlobalAppState.of(context);

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return _OrderCard(order: filteredOrders[index], onUpdateStatus: state.updateOrderStatus);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Function(String, OrderStatus) onUpdateStatus;

  const _OrderCard({required this.order, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.id.substring(order.id.length - 6)}', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: Text(order.status.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: kPrimaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.items.length} items', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                Text(currency.format(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            if (order.status == OrderStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onUpdateStatus(order.id, OrderStatus.accepted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    child: const Text('Accept Order'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
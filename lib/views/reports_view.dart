// views/reports_view.dart
import 'package:flutter/material.dart';
import '../models.dart';

class ReportsView extends StatelessWidget {
  final List<Order> orders;
  final List<InventoryItem> inventory;

  const ReportsView({super.key, required this.orders, required this.inventory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle, 
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]
            ),
            child: Icon(Icons.bar_chart_rounded, size: 64, color: Colors.blue.shade200),
          ),
          const SizedBox(height: 32),
          const Text('Analytics Coming Soon', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'This module connects to Supabase\nto visualize your sales trends.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, height: 1.5),
          ),
        ],
      ),
    );
  }
}
// models.dart
import 'package:flutter/material.dart';

// --- Styling Constants ---
const Color kPrimaryColor = Color(0xFF0F9873);
const Color kBackgroundColor = Color(0xFFF0F4F8); // Softer cool grey
const String kInternalBusinessId = 'SUP-8829-X';

// --- Enums ---
enum OrderStatus { pending, accepted, shipped, delivered }

// --- Data Models ---
class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String barcode;
  double stock;
  final double price;
  final String unit;
  final int lowStockThreshold;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.barcode,
    required this.stock,
    required this.price,
    required this.unit,
    required this.lowStockThreshold,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      barcode: json['barcode'] ?? '',
      // Safely handle numbers from DB
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'units',
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'barcode': barcode,
      'stock': stock,
      'price': price,
      'unit': unit,
      'low_stock_threshold': lowStockThreshold,
    };
  }
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['item_id'] ?? '',
      itemName: json['item_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson(String orderId) {
    return {
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String customerName;
  final DateTime date;
  OrderStatus status;
  final List<OrderItem> items;
  final double totalAmount;

  Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.status,
    required this.items,
    required this.totalAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['order_items'] as List<dynamic>?;
    List<OrderItem> itemsList = list != null
        ? list.map((i) => OrderItem.fromJson(i)).toList()
        : [];

    return Order(
      id: json['id'],
      customerName: json['customer_name'] ?? 'Unknown',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: OrderStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => OrderStatus.pending),
      items: itemsList,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
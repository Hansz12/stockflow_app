// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // REQUIRED: Add to pubspec
import 'models.dart';
import 'screens/role_switcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual Supabase keys
  await Supabase.initialize(
    url: 'https://xlyqczdgagzuyacwomqh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhseXFjemRnYWd6dXlhY3dvbXFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4MDExOTgsImV4cCI6MjA4NDM3NzE5OH0.yjeDBpPY1_UooZzFoO3P7l8CXpnLRHgJb-n3ZmxEhsg',
  );

  runApp(const SupplierApp());
}

// Global State
class GlobalAppState extends InheritedWidget {
  final List<Order> orders;
  final List<InventoryItem> inventory;
  final bool isLoading;
  final Function(Order) addOrder;
  final Function(String, OrderStatus) updateOrderStatus;
  final Function(String, double) updateStock;

  const GlobalAppState({
    super.key,
    required this.orders,
    required this.inventory,
    required this.isLoading,
    required this.addOrder,
    required this.updateOrderStatus,
    required this.updateStock,
    required super.child,
  });

  static GlobalAppState of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<GlobalAppState>();
    assert(result != null, 'No GlobalAppState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(GlobalAppState oldWidget) {
    return orders != oldWidget.orders || 
           inventory != oldWidget.inventory ||
           isLoading != oldWidget.isLoading;
  }
}

class SupplierApp extends StatefulWidget {
  const SupplierApp({super.key});

  @override
  State<SupplierApp> createState() => _SupplierAppState();
}

class _SupplierAppState extends State<SupplierApp> {
  final _supabase = Supabase.instance.client;
  
  List<Order> _orders = [];
  List<InventoryItem> _inventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);
      
      final inventoryData = await _supabase.from('inventory').select().order('name', ascending: true);
      final fetchedInventory = (inventoryData as List).map((i) => InventoryItem.fromJson(i)).toList();

      final ordersData = await _supabase.from('orders').select('*, order_items(*)').order('date', ascending: false);
      final fetchedOrders = (ordersData as List).map((o) => Order.fromJson(o)).toList();

      setState(() {
        _inventory = fetchedInventory;
        _orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrder(Order order) async {
    try {
      setState(() => _orders.insert(0, order));

      await _supabase.from('orders').insert({
        'id': order.id,
        'customer_name': order.customerName,
        'date': order.date.toIso8601String(),
        'status': order.status.name,
        'total_amount': order.totalAmount,
      });

      for (var item in order.items) {
        await _supabase.from('order_items').insert(item.toJson(order.id));
      }
    } catch (e) {
      debugPrint('Error adding order: $e');
    }
  }

  Future<void> _updateOrderStatus(String id, OrderStatus newStatus) async {
    try {
      setState(() {
        final index = _orders.indexWhere((o) => o.id == id);
        if (index != -1) _orders[index].status = newStatus;
      });

      await _supabase.from('orders').update({'status': newStatus.name}).eq('id', id);
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> _updateStock(String id, double change) async {
    try {
      final index = _inventory.indexWhere((item) => item.id == id);
      if (index == -1) return;

      double currentStock = _inventory[index].stock;
      double newStock = (currentStock + change).clamp(0, 9999);

      setState(() {
        _inventory[index].stock = newStock;
      });

      await _supabase.from('inventory').update({'stock': newStock}).eq('id', id);
    } catch (e) {
      debugPrint('Error updating stock: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalAppState(
      orders: _orders,
      inventory: _inventory,
      isLoading: _isLoading,
      addOrder: _addOrder,
      updateOrderStatus: _updateOrderStatus,
      updateStock: _updateStock,
      child: MaterialApp(
        title: 'StockFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // --- THEME & FONT SETTINGS ---
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: kBackgroundColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: kPrimaryColor,
            secondary: Colors.tealAccent,
            surface: Colors.white,
          ),
          // Using Poppins for that "Cute & Formal" look
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87
            ),
          ),
          useMaterial3: true,
        ),
        home: const RoleSwitcher(),
      ),
    );
  }
}
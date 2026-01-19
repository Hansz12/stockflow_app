// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../views/home_view.dart';
import '../views/orders_view.dart';
import '../views/inventory_view.dart';
import '../views/reports_view.dart';
import '../views/profile_view.dart';

class DashboardScreen extends StatefulWidget {
  final bool isSupplier;
  final ValueChanged<bool> onToggleRole;

  const DashboardScreen({super.key, required this.isSupplier, required this.onToggleRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; 
  String _activeOrdersTab = 'pending'; 

  List<Widget> _getViews(GlobalAppState state) {
    return [
      const HomeView(), // 0
      OrdersView(activeTab: _activeOrdersTab, orders: state.orders), // 1
      InventoryView(inventory: state.inventory), // 2
      ReportsView(orders: state.orders, inventory: state.inventory), // 3
      const ProfileView(), // 4
    ];
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Overview';
      case 1: return 'Orders';
      case 2: return 'Inventory';
      case 3: return 'Analytics';
      case 4: return 'Profile';
      default: return 'StockFlow';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = GlobalAppState.of(context);
    
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kPrimaryColor)));
    }

    final views = _getViews(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined), 
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          if (_selectedIndex == 1) _buildOrderTabs(),
          Expanded(
            child: Container(
              color: kBackgroundColor,
              padding: const EdgeInsets.all(16),
              child: views[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Stock'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Manager Mode", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("StockFlow Admin"),
            currentAccountPicture: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: const Icon(Icons.admin_panel_settings, color: kPrimaryColor, size: 30),
            ),
            decoration: const BoxDecoration(color: kPrimaryColor),
          ),
          _buildDrawerItem(0, 'Dashboard', Icons.dashboard_rounded),
          _buildDrawerItem(1, 'Orders', Icons.receipt_long_rounded),
          _buildDrawerItem(2, 'Inventory', Icons.inventory_2_rounded),
          _buildDrawerItem(3, 'Analytics', Icons.bar_chart_rounded),
          const Divider(),
          _buildDrawerItem(4, 'Profile', Icons.person_rounded),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => widget.onToggleRole(false),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text("Switch to Staff Mode"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade800,
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? kPrimaryColor : Colors.grey),
      title: Text(title, style: TextStyle(
        color: isSelected ? kPrimaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      )),
      selected: isSelected,
      // ignore: deprecated_member_use
      selectedTileColor: kPrimaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); 
      },
    );
  }

  Widget _buildOrderTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildTab('Pending', 'pending'),
          const SizedBox(width: 10),
          _buildTab('Accepted', 'accepted'),
          const SizedBox(width: 10),
          _buildTab('Shipped', 'shipped'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String id) {
    final isActive = _activeOrdersTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeOrdersTab = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            boxShadow: isActive ? [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
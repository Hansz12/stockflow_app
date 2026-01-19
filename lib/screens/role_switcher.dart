// screens/role_switcher.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'customer_shop_screen.dart';

class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  // Toggle state
  bool isManager = true; 

  void toggleRole(bool requestManagerMode) {
    setState(() {
      isManager = requestManagerMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedSwitcher makes the transition between roles look smooth/cute
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isManager
          ? DashboardScreen(
              key: const ValueKey('Manager'),
              isSupplier: true,
              onToggleRole: (val) => toggleRole(val),
            )
          : CustomerShopScreen(
              key: const ValueKey('Staff'),
              isSupplier: false,
              onToggleRole: (val) => toggleRole(val),
            ),
    );
  }
}
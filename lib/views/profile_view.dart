// views/profile_view.dart
import 'package:flutter/material.dart';
import '../models.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: CircleAvatar(
              radius: 50,
              // ignore: deprecated_member_use
              backgroundColor: kPrimaryColor.withOpacity(0.1),
              child: const Icon(Icons.person, size: 50, color: kPrimaryColor),
            ),
          ),
          const SizedBox(height: 16),
          const Text('John Doe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('Business Owner', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          const _ProfileItem(icon: Icons.badge_outlined, label: 'Business ID', value: kInternalBusinessId),
          const _ProfileItem(icon: Icons.email_outlined, label: 'Email', value: 'john@stockflow.com'),
          const _ProfileItem(icon: Icons.phone_outlined, label: 'Phone', value: '+60 12-345 6789'),
          const _ProfileItem(icon: Icons.location_on_outlined, label: 'Location', value: 'Selangor, Malaysia'),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade400),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  static const String routeName = '/inventory';

  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Inventory management UI will be here',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

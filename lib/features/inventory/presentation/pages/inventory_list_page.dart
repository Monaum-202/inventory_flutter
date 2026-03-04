import 'package:flutter/material.dart';

class InventoryListPage extends StatelessWidget {
  static const String routeName = '/inventory';

  const InventoryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: const Center(child: Text('Inventory list will be shown here')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/providers/auth_provider.dart';
import '../../main.dart';

/// A standard navigation drawer used across the app.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Inventory App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              ref.read(pageIndexProvider.notifier).state = 0;
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              ref.read(pageIndexProvider.notifier).state = 1;
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Reports'),
            children: [
              ListTile(
                leading: const Icon(Icons.inventory_2),
                title: const Text('Inventory Report'),
                onTap: () {
                  ref.read(pageIndexProvider.notifier).state = 2;
                  ref.read(reportsSubIndexProvider.notifier).state = 0;
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Purchase Report'),
                onTap: () {
                  ref.read(pageIndexProvider.notifier).state = 2;
                  ref.read(reportsSubIndexProvider.notifier).state = 1;
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell),
                title: const Text('Sales Report'),
                onTap: () {
                  ref.read(pageIndexProvider.notifier).state = 2;
                  ref.read(reportsSubIndexProvider.notifier).state = 2;
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Income Report'),
                onTap: () {
                  ref.read(pageIndexProvider.notifier).state = 2;
                  ref.read(reportsSubIndexProvider.notifier).state = 3;
                },
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/data/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'core/themes/app_theme.dart';
import 'core/widgets/app_drawer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: InventoryApp()));
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _RootNavigator(),
    );
  }
}

/// Page index provider for navigation
final pageIndexProvider = StateProvider<int>((ref) => 0);

/// Reports sub index provider
final reportsSubIndexProvider = StateProvider<int>((ref) => 0);

/// Decides whether to show login or the main app based on auth state.
class _RootNavigator extends ConsumerWidget {
  const _RootNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Show login screen if not authenticated
    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    // Show dashboard directly if authenticated
    return const _MainApp();
  }
}

class _MainApp extends ConsumerWidget {
  const _MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(pageIndex)),
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Implement profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon!')),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: IndexedStack(
        index: pageIndex,
        children: const [DashboardPage(), InventoryPage(), ReportsPage()],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Inventory';
      case 2:
        return 'Reports';
      default:
        return 'Inventory App';
    }
  }
}

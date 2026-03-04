import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/data/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'core/themes/app_theme.dart';
import 'core/navigation/professional_sidebar.dart';
import 'core/navigation/navigation_model.dart';

void main() {
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

    // Show main app if authenticated
    return const _MainApp();
  }
}

/// Page state provider to track which page to display
final pageIndexProvider = StateProvider<int>((ref) => 0);

class _MainApp extends ConsumerWidget {
  const _MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(pageIndexProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // Define pages in order
    final pages = [
      const DashboardPage(),
      const InventoryPage(),
      const ReportsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapid Global Inventory'),
        elevation: 0,
      ),
      drawer: isMobile
          ? _buildNavigationDrawer(context, ref)
          : null,
      body: isMobile
          ? pages[pageIndex]
          : Row(
              children: [
                ProfessionalNavigationSidebar(
                  modules: defaultNavigationModules,
                  onMenuSelected: (menu) {
                    _handleMenuSelection(menu, ref);
                  },
                ),
                Expanded(
                  child: pages[pageIndex],
                ),
              ],
            ),
    );
  }

  /// Build navigation drawer for mobile
  Widget _buildNavigationDrawer(BuildContext context, WidgetRef ref) {
    return ProfessionalNavigationSidebar(
      modules: defaultNavigationModules,
      onMenuSelected: (menu) {
        Navigator.pop(context); // Close drawer
        _handleMenuSelection(menu, ref);
      },
    );
  }

  /// Handle menu selection - map routes to page indices
  void _handleMenuSelection(NavigationMenu menu, WidgetRef ref) {
    switch (menu.route) {
      case '/':
      case '/dashboard':
        ref.read(pageIndexProvider.notifier).state = 0;
        break;
      case '/inventory':
      case '/categories':
      case '/stock':
        ref.read(pageIndexProvider.notifier).state = 1;
        break;
      case '/reports/sales':
      case '/reports/inventory':
      case '/export':
        ref.read(pageIndexProvider.notifier).state = 2;
        break;
      default:
        ref.read(pageIndexProvider.notifier).state = 0;
    }
  }
}

// Additional feature entry points and providers live inside the feature
// directories under `lib/features`. Maintain a clear separation between
// presentation, domain, and data layers as recommended by the Clean
// Architecture pattern.

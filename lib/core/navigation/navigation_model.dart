import 'package:flutter/material.dart';

/// Navigation data model for modules and menus
class NavigationModule {
  NavigationModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.menus,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<NavigationMenu> menus;
}

class NavigationMenu {
  NavigationMenu({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
  });

  final String id;
  final String title;
  final IconData icon;
  final String route;
}

/// Sample navigation structure for the app
final defaultNavigationModules = [
  NavigationModule(
    id: 'dashboard',
    title: 'Dashboard',
    icon: Icons.dashboard,
    menus: [
      NavigationMenu(
        id: 'overview',
        title: 'Overview',
        icon: Icons.bar_chart,
        route: '/',
      ),
      NavigationMenu(
        id: 'analytics',
        title: 'Analytics',
        icon: Icons.analytics,
        route: '/analytics',
      ),
    ],
  ),
  NavigationModule(
    id: 'inventory',
    title: 'Inventory',
    icon: Icons.inventory_2,
    menus: [
      NavigationMenu(
        id: 'items',
        title: 'Items',
        icon: Icons.list,
        route: '/inventory',
      ),
      NavigationMenu(
        id: 'categories',
        title: 'Categories',
        icon: Icons.category,
        route: '/categories',
      ),
      NavigationMenu(
        id: 'stock',
        title: 'Stock Levels',
        icon: Icons.storage,
        route: '/stock',
      ),
    ],
  ),
  NavigationModule(
    id: 'reports',
    title: 'Reports',
    icon: Icons.assessment,
    menus: [
      NavigationMenu(
        id: 'sales',
        title: 'Sales Report',
        icon: Icons.trending_up,
        route: '/reports/sales',
      ),
      NavigationMenu(
        id: 'inventory_report',
        title: 'Inventory Report',
        icon: Icons.assignment,
        route: '/reports/inventory',
      ),
      NavigationMenu(
        id: 'export',
        title: 'Export',
        icon: Icons.file_download,
        route: '/export',
      ),
    ],
  ),
];

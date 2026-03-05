import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/navigation_model.dart';

// Providers for sidebar state
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final expandedModuleProvider = StateProvider<String?>((ref) => null);

class ProfessionalSidebar extends ConsumerWidget {
  const ProfessionalSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Mobile: Use Drawer
    if (screenWidth < 600) {
      return _MobileDrawer();
    }

    // Desktop/Tablet: Collapsible Sidebar
    return _CollapsibleSidebar();
  }
}

class _MobileDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          _SidebarHeader(),
          Expanded(
            child: _ModuleList(),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleSidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 250,
      color: Colors.black,
      child: Column(
        children: [
          _SidebarHeader(isCollapsed: isCollapsed),
          Expanded(
            child: _ModuleList(isCollapsed: isCollapsed),
          ),
          // Toggle button
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                color: const Color(0xFFFF6B6B),
              ),
              onPressed: () {
                ref.read(sidebarCollapsedProvider.notifier).state = !isCollapsed;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool isCollapsed;

  const _SidebarHeader({this.isCollapsed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Color(0xFFFF6B6B), width: 1),
        ),
      ),
      child: isCollapsed
          ? const Text(
              'RG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
          : const Text(
              'Rapid Global',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}

class _ModuleList extends ConsumerWidget {
  final bool isCollapsed;

  const _ModuleList({this.isCollapsed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedModule = ref.watch(expandedModuleProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: defaultNavigationModules.map((module) {
        return Column(
          children: [
            _ModuleTile(
              module: module,
              isExpanded: expandedModule == module.id,
              isCollapsed: isCollapsed,
              onExpansionChanged: (expanded) {
                ref.read(expandedModuleProvider.notifier).state =
                    expanded ? module.id : null;
              },
            ),
            if (defaultNavigationModules.last != module)
              const Divider(color: Color(0xFFFF6B6B), height: 1, thickness: 0.5),
          ],
        );
      }).toList(),
    );
  }
}

class _ModuleTile extends ConsumerWidget {
  final NavigationModule module;
  final bool isExpanded;
  final bool isCollapsed;
  final ValueChanged<bool> onExpansionChanged;

  const _ModuleTile({
    required this.module,
    required this.isExpanded,
    required this.isCollapsed,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isCollapsed) {
      return IconButton(
        icon: Icon(module.icon, color: Colors.white),
        onPressed: () => onExpansionChanged(!isExpanded),
        tooltip: module.title,
      );
    }

    return ExpansionTile(
      title: Text(
        module.title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      leading: Icon(module.icon, color: Colors.white, size: 24),
      backgroundColor: Colors.black,
      collapsedBackgroundColor: Colors.black,
      iconColor: const Color(0xFFFF6B6B),
      collapsedIconColor: const Color(0xFFFF6B6B),
      onExpansionChanged: onExpansionChanged,
      initiallyExpanded: isExpanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: module.menus.map((menu) {
        return _MenuTile(menu: menu);
      }).toList(),
    );
  }
}

class _MenuTile extends ConsumerStatefulWidget {
  final NavigationMenu menu;

  const _MenuTile({required this.menu});

  @override
  _MenuTileState createState() => _MenuTileState();
}

class _MenuTileState extends ConsumerState<_MenuTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Assume current route is dashboard for now
    final isActive = widget.menu.route == '/'; // Adjust based on current route

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        transform: Matrix4.translationValues(
          (isActive || _isHovered) ? 8.0 : 0.0,
          0.0,
          0.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFF5252)
                : _isHovered
                    ? const Color(0xFFFF6B6B).withOpacity(0.2)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              widget.menu.title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            leading: Icon(widget.menu.icon, color: Colors.white, size: 20),
            onTap: () {
              // Navigate to route
              // Navigator.of(context).pushNamed(widget.menu.route);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

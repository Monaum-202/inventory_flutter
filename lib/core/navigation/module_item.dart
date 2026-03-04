import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation_model.dart';
import 'navigation_provider.dart';
import 'nav_constants.dart';

/// Expandable module item with submenu items
class ModuleItem extends ConsumerWidget {
  const ModuleItem({
    required this.module,
    required this.isCollapsed,
    required this.onModuleClick,
    required this.onMenuClick,
    super.key,
  });

  final NavigationModule module;
  final bool isCollapsed;
  final VoidCallback onModuleClick;
  final Function(NavigationMenu) onMenuClick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedModule = ref.watch(expandedModuleProvider);
    final activeMenu = ref.watch(activeMenuProvider);
    final isExpanded = expandedModule == module.id;

    return Column(
      children: [
        // Module Header
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8 : 12,
            vertical: 4,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onModuleClick,
              borderRadius: BorderRadius.circular(NavSizing.borderRadius),
              hoverColor: NavColors.activeHover.withValues(alpha: 0.2),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isExpanded ? NavColors.activeBackground.withValues(alpha: 0.1) : null,
                  borderRadius: BorderRadius.circular(NavSizing.borderRadius),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: NavSizing.iconMinWidth,
                      child: Icon(
                        module.icon,
                        size: NavSizing.moduleIconSize,
                        color: NavColors.text,
                      ),
                    ),
                    if (!isCollapsed) ...[
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          module.title,
                          style: TextStyle(
                            color: NavColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: Duration(
                          milliseconds: NavSizing.animationDuration.toInt(),
                        ),
                        child: Icon(
                          Icons.expand_more,
                          color: NavColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        // Submenu Items
        if (isExpanded && !isCollapsed)
          Padding(
            padding: EdgeInsets.only(left: 32),
            child: Column(
              children: module.menus
                  .map(
                    (menu) => _MenuItemTile(
                      menu: menu,
                      isActive: activeMenu == menu.id,
                      onTap: () {
                        ref.read(activeMenuProvider.notifier).state = menu.id;
                        onMenuClick(menu);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

/// Individual menu item (submenu of a module)
class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.menu,
    required this.isActive,
    required this.onTap,
  });

  final NavigationMenu menu;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NavSizing.borderRadius),
          hoverColor: NavColors.activeHover.withValues(alpha: 0.15),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? NavColors.activeBackground : null,
              borderRadius: BorderRadius.circular(NavSizing.borderRadius),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: NavSizing.iconMinWidth,
                  child: Icon(
                    menu.icon,
                    size: NavSizing.menuIconSize,
                    color: isActive ? Colors.white : NavColors.textSecondary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    menu.title,
                    style: TextStyle(
                      color: isActive ? Colors.white : NavColors.textSecondary,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation_model.dart';
import 'navigation_provider.dart';
import 'nav_constants.dart';
import 'module_item.dart';

/// Professional responsive sidebar wrapper
/// Handles mobile (Drawer) and desktop (Collapsible Sidebar) layouts
class ProfessionalNavigationSidebar extends ConsumerWidget {
  const ProfessionalNavigationSidebar({
    this.modules = const [],
    required this.onMenuSelected,
    super.key,
  });

  final List<NavigationModule> modules;
  final Function(NavigationMenu) onMenuSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return _buildDrawer(ref);
    } else {
      return _buildDesktopSidebar(ref);
    }
  }

  /// Mobile drawer version
  Widget _buildDrawer(WidgetRef ref) {
    return Drawer(
      backgroundColor: NavColors.background,
      child: _buildSidebarContent(ref, isCollapsed: false),
    );
  }

  /// Desktop collapsible sidebar
  Widget _buildDesktopSidebar(WidgetRef ref) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return AnimatedContainer(
      width: isCollapsed
          ? NavSizing.sidebarCollapsedWidth
          : NavSizing.sidebarExpandedWidth,
      duration: Duration(
        milliseconds: NavSizing.animationDuration.toInt(),
      ),
      color: NavColors.background,
      child: Column(
        children: [
          // Toggle button
          SizedBox(
            height: 60,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(sidebarCollapsedProvider.notifier).state =
                      !isCollapsed;
                },
                child: Tooltip(
                  message: isCollapsed ? 'Expand' : 'Collapse',
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      isCollapsed
                          ? Icons.chevron_right
                          : Icons.chevron_left,
                      color: NavColors.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Sidebar content
          Expanded(
            child: _buildSidebarContent(ref, isCollapsed: isCollapsed),
          ),
        ],
      ),
    );
  }

  /// Shared sidebar content
  Widget _buildSidebarContent(WidgetRef ref, {required bool isCollapsed}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (!isCollapsed)
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Text(
                'Rapid Global',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NavColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            SizedBox(height: 24),
          Divider(
            color: NavColors.divider,
            height: 1,
            indent: isCollapsed ? 8 : 0,
            endIndent: isCollapsed ? 8 : 0,
          ),
          SizedBox(height: 8),
          // Modules
          ...modules.map(
            (module) => ModuleItem(
              module: module,
              isCollapsed: isCollapsed,
              onModuleClick: () {
                ref.read(expandedModuleProvider.notifier).state =
                    ref.read(expandedModuleProvider) == module.id
                        ? null
                        : module.id;
              },
              onMenuClick: (menu) {
                onMenuSelected(menu);
              },
            ),
          ),
        ],
      ),
    );
  }
}

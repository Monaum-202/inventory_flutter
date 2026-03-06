import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/providers/auth_provider.dart';
import '../../main.dart';

// ─── Theme constants matching your CSS ───────────────────────────────────────
const _kSidebarBg = Color(0xFF000000);
const _kActiveRed = Color(0xFFFF5252);
const _kHoverRed = Color(0xFFFF6B6B);
const _kTextWhite = Colors.white;
const _kDividerColor = Color(0x33FFFFFF); // rgba(255,255,255,0.2)
const _kSubItemIndent = 28.0;

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with SingleTickerProviderStateMixin {
  bool _reportsExpanded = false;
  late AnimationController _chevronController;
  late Animation<double> _chevronRotation;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _chevronRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  void _toggleReports() {
    setState(() {
      _reportsExpanded = !_reportsExpanded;
      if (_reportsExpanded) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(pageIndexProvider);
    final reportsSubIndex = ref.watch(reportsSubIndexProvider);

    return Drawer(
      width: 250,
      backgroundColor: _kSidebarBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _DrawerHeader(),

          // ── Scrollable nav area ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                // 1. Dashboard
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: pageIndex == 0,
                  onTap: () {
                    ref.read(pageIndexProvider.notifier).state = 0;
                    Navigator.of(context).pop();
                  },
                ),

                // ── Divider ────────────────────────────────────────────────
                const _SidebarDivider(),

                // 2. Reports (expandable)
                _ReportsModule(
                  isExpanded: _reportsExpanded,
                  chevronRotation: _chevronRotation,
                  onToggle: _toggleReports,
                  activeSubIndex: pageIndex == 2 ? reportsSubIndex : -1,
                  onSubItemTap: (subIndex) {
                    ref.read(pageIndexProvider.notifier).state = 2;
                    ref.read(reportsSubIndexProvider.notifier).state = subIndex;
                    Navigator.of(context).pop();
                  },
                ),

                // ── Divider ────────────────────────────────────────────────
                const _SidebarDivider(),

                // 3. Inventory
                _NavItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventory',
                  isActive: pageIndex == 1,
                  onTap: () {
                    ref.read(pageIndexProvider.notifier).state = 1;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),

          // ── Logout pinned at bottom ─────────────────────────────────────────
          const _SidebarDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: _NavItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              isActive: false,
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authStateProvider.notifier).logout();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      decoration: const BoxDecoration(
        color: _kSidebarBg,
        border: Border(
          bottom: BorderSide(color: _kDividerColor, width: 1),
        ),
      ),
      child: const Text(
        'Rapid Global',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _kTextWhite,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Single nav item ─────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final double indent;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.indent = 0,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.isActive || _hovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.fromLTRB(
            10.0 + widget.indent,
            10,
            10,
            10,
          ),
          decoration: BoxDecoration(
            color: highlighted ? _kActiveRed : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          transform: highlighted
              ? (Matrix4.identity()..translate(5.0))
              : Matrix4.identity(),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: _kTextWhite,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: _kTextWhite,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reports expandable module ───────────────────────────────────────────────
class _ReportsModule extends StatelessWidget {
  final bool isExpanded;
  final Animation<double> chevronRotation;
  final VoidCallback onToggle;
  final int activeSubIndex;
  final ValueChanged<int> onSubItemTap;

  static const _reportItems = [
    (icon: Icons.inventory_2_outlined, label: 'Inventory Report', index: 0),
    (icon: Icons.shopping_cart_outlined, label: 'Purchase Report', index: 1),
    (icon: Icons.sell_outlined, label: 'Sales Report', index: 2),
    (icon: Icons.attach_money_rounded, label: 'Income Report', index: 3),
  ];

  const _ReportsModule({
    required this.isExpanded,
    required this.chevronRotation,
    required this.onToggle,
    required this.activeSubIndex,
    required this.onSubItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Module header row
        GestureDetector(
          onTap: onToggle,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: _kTextWhite,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Reports',
                    style: TextStyle(
                      color: _kTextWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Chevron rotates on expand
                RotationTransition(
                  turns: chevronRotation,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _kTextWhite,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sub-items with animated expand
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: _reportItems
                .map(
                  (item) => _NavItem(
                    icon: item.icon,
                    label: item.label,
                    isActive: activeSubIndex == item.index,
                    indent: _kSubItemIndent,
                    onTap: () => onSubItemTap(item.index),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────
class _SidebarDivider extends StatelessWidget {
  const _SidebarDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: _kDividerColor,
      thickness: 1,
      height: 16,
      indent: 8,
      endIndent: 8,
    );
  }
}
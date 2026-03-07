import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_report_provider.dart';
import '../widgets/dashboard_view_widget.dart';
import '../widgets/filter_section_widget.dart';
import '../widgets/products_customers_widgets.dart';
import '../widgets/sales_table_widget.dart';

class SalesReportPage extends ConsumerWidget {
  const SalesReportPage({super.key});

  static const _tabs = [
    _TabItem(SalesReportView.dashboard, Icons.speed_rounded, 'Dashboard'),
    _TabItem(SalesReportView.table, Icons.receipt_long_rounded, 'Sales'),
    _TabItem(SalesReportView.products, Icons.inventory_2_rounded, 'Products'),
    _TabItem(SalesReportView.customers, Icons.people_alt_rounded, 'Customers'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesReportProvider);
    final notifier = ref.read(salesReportProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          children: [
            _AppBarIcon(),
            SizedBox(width: 10),
            Text(
              'Sales Report',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1D23),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _TabBar(
            activeView: state.activeView,
            onChanged: notifier.switchView,
            tabs: _tabs,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FilterSectionWidget(),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(state.activeView),
                    child: _buildActiveView(state.activeView),
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoading ||
              state.isLoadingProducts ||
              state.isLoadingCustomers)
            const _LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildActiveView(SalesReportView view) {
    return switch (view) {
      SalesReportView.dashboard => const DashboardViewWidget(),
      SalesReportView.table    => const SalesTableWidget(),
      SalesReportView.products => const ProductsViewWidget(),
      SalesReportView.customers => const CustomersViewWidget(),
    };
  }
}

// ─────────────────────────────────────────────
// Custom Tab Bar
// ─────────────────────────────────────────────

class _TabItem {
  final SalesReportView view;
  final IconData icon;
  final String label;
  const _TabItem(this.view, this.icon, this.label);
}

class _TabBar extends StatelessWidget {
  final SalesReportView activeView;
  final ValueChanged<SalesReportView> onChanged;
  final List<_TabItem> tabs;

  const _TabBar({
    required this.activeView,
    required this.onChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: tabs.map((tab) {
            final isActive = tab.view == activeView;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(tab.view),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 14,
                        color: isActive
                            ? const Color(0xFF4C9EFF)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF1A1D23)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _AppBarIcon extends StatelessWidget {
  const _AppBarIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C9EFF), Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(Icons.bar_chart_rounded,
          size: 18, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF4C9EFF)),
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Loading…',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
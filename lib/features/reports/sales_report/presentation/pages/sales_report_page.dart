import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_report_provider.dart';
import '../widgets/dashboard_view_widget.dart';
import '../widgets/filter_section_widget.dart';
import '../widgets/products_customers_widgets.dart';
import '../widgets/sales_table_widget.dart';

class SalesReportPage extends ConsumerWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesReportProvider);
    final notifier = ref.read(salesReportProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bar_chart, size: 20),
            SizedBox(width: 8),
            Text('Sales Report'),
          ],
        ),
        actions: [
          // View toggle buttons
          _ViewToggle(
            activeView: state.activeView,
            onChanged: notifier.switchView,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Filters ──────────────────────────────────
                const FilterSectionWidget(),
                const SizedBox(height: 16),

                // ─── Content ──────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildActiveView(state.activeView),
                ),
              ],
            ),
          ),

          // ─── Global loading overlay ─────────────────────────
          if (state.isLoading || state.isLoadingProducts || state.isLoadingCustomers)
            const _LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildActiveView(SalesReportView view) {
    return switch (view) {
      SalesReportView.dashboard => const DashboardViewWidget(),
      SalesReportView.table => const SalesTableWidget(),
      SalesReportView.products => const ProductsViewWidget(),
      SalesReportView.customers => const CustomersViewWidget(),
    };
  }
}

// ─────────────────────────────────────────────
class _ViewToggle extends StatelessWidget {
  final SalesReportView activeView;
  final ValueChanged<SalesReportView> onChanged;

  const _ViewToggle({required this.activeView, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SalesReportView>(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12),
      ),
      selected: {activeView},
      onSelectionChanged: (s) => onChanged(s.first),
      segments: const [
        ButtonSegment(
          value: SalesReportView.dashboard,
          icon: Icon(Icons.speed, size: 15),
          label: Text('Dashboard'),
        ),
        ButtonSegment(
          value: SalesReportView.table,
          icon: Icon(Icons.table_rows, size: 15),
          label: Text('Sales'),
        ),
        ButtonSegment(
          value: SalesReportView.products,
          icon: Icon(Icons.inventory_2, size: 15),
          label: Text('Products'),
        ),
        ButtonSegment(
          value: SalesReportView.customers,
          icon: Icon(Icons.people, size: 15),
          label: Text('Customers'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.15),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
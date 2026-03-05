import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/dashboard_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/inventory_card.dart';

class DashboardPage extends ConsumerWidget {
  static const String routeName = '/dashboard';

  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider(selectedPeriod));
    final stockAsync = ref.watch(dashboardStockProvider);
    final revenueAsync = ref.watch(dashboardRevenueProvider(selectedPeriod));

    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    'Business overview',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              _RefreshButton(period: selectedPeriod),
            ],
          ),
          const SizedBox(height: 16),

          // ── Period Filter ────────────────────────────────────────
          _PeriodFilter(selectedPeriod: selectedPeriod, ref: ref),
          const SizedBox(height: 16),

          // ── Metrics ──────────────────────────────────────────────
          metricsAsync.when(
            data: (metrics) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'Key Metrics'),
                const SizedBox(height: 10),
                _MetricsGrid(
                  context: context,
                  children: [
                    MetricCard(
                      title: 'Total Revenue',
                      value: metrics.totalRevenue.formattedValue,
                      change: metrics.totalRevenue.formattedChange,
                      isPositive: metrics.totalRevenue.positive,
                      bgColor: const Color(0xFF16A34A).withValues(alpha: 0.1),
                      accentColor: const Color(0xFF16A34A),
                      icon: Icons.trending_up_rounded,
                    ),
                    MetricCard(
                      title: 'Total Expenses',
                      value: metrics.totalExpenses.formattedValue,
                      change: metrics.totalExpenses.formattedChange,
                      isPositive: metrics.totalExpenses.positive,
                      bgColor: const Color(0xFFDC2626).withValues(alpha: 0.1),
                      accentColor: const Color(0xFFDC2626),
                      icon: Icons.trending_down_rounded,
                    ),
                    MetricCard(
                      title: 'Net Profit',
                      value: metrics.netProfit.formattedValue,
                      change: metrics.netProfit.formattedChange,
                      isPositive: metrics.netProfit.positive,
                      bgColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      accentColor: const Color(0xFF2563EB),
                      icon: Icons.attach_money_rounded,
                    ),
                    MetricCard(
                      title: 'Profit Margin',
                      value: metrics.profitMargin.formattedValue,
                      change: metrics.profitMargin.formattedChange,
                      isPositive: metrics.profitMargin.positive,
                      bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                      accentColor: const Color(0xFF7C3AED),
                      icon: Icons.percent_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Operations'),
                const SizedBox(height: 10),
                _MetricsGrid(
                  context: context,
                  children: [
                    MetricCard(
                      title: 'Total Orders',
                      value: metrics.totalOrders.formattedValue,
                      change: metrics.totalOrders.formattedChange,
                      isPositive: metrics.totalOrders.positive,
                      bgColor: const Color(0xFFEA580C).withValues(alpha: 0.1),
                      accentColor: const Color(0xFFEA580C),
                      icon: Icons.shopping_bag_rounded,
                    ),
                    MetricCard(
                      title: 'Total Customers',
                      value: metrics.totalCustomers.formattedValue,
                      change: metrics.totalCustomers.formattedChange,
                      isPositive: metrics.totalCustomers.positive,
                      bgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                      accentColor: const Color(0xFF0D9488),
                      icon: Icons.people_alt_rounded,
                    ),
                    MetricCard(
                      title: 'Total Due',
                      value: metrics.totalDue.formattedValue,
                      change: metrics.totalDue.formattedChange,
                      isPositive: metrics.totalDue.positive,
                      bgColor: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      accentColor: const Color(0xFF4F46E5),
                      icon: Icons.receipt_long_rounded,
                    ),
                    MetricCard(
                      title: 'Total Owed',
                      value: metrics.totalOwed.formattedValue,
                      change: metrics.totalOwed.formattedChange,
                      isPositive: metrics.totalOwed.positive,
                      bgColor: const Color(0xFFCA8A04).withValues(alpha: 0.1),
                      accentColor: const Color(0xFFCA8A04),
                      icon: Icons.account_balance_rounded,
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const _LoadingPlaceholder(height: 280),
            error: (e, _) => _ErrorMessage(message: 'Could not load metrics'),
          ),
          const SizedBox(height: 20),

          // ── Inventory ────────────────────────────────────────────
          stockAsync.when(
            data: (stock) => _SectionCard(
              title: 'Inventory Status',
              trailing: Text(
                '${stock.stocks.length} items',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 140,
                  childAspectRatio: 1.05,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: stock.stocks.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  const colors = [
                    Color(0xFFDC2626),
                    Color(0xFF2563EB),
                    Color(0xFF16A34A),
                    Color(0xFFEA580C),
                    Color(0xFF7C3AED),
                    Color(0xFF0D9488),
                  ];
                  final item = stock.stocks[index];
                  return InventoryCard(
                    label: item.productName,
                    count: item.stockAmount,
                    color: colors[index % colors.length],
                  );
                },
              ),
            ),
            loading: () => const _LoadingPlaceholder(height: 180),
            error: (e, _) => _ErrorMessage(message: 'Could not load inventory'),
          ),
          const SizedBox(height: 20),

          // ── Revenue Details ──────────────────────────────────────
          revenueAsync.when(
            data: (revenue) => _SectionCard(
              title: 'Revenue Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Revenue',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          revenue.categoryBreakdown.isNotEmpty
                              ? revenue.categoryBreakdown[0].amount.toStringAsFixed(2)
                              : '0.00',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (revenue.categoryBreakdown.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'BY CATEGORY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...revenue.categoryBreakdown.map((cat) => _CategoryRow(cat: cat)),
                  ],
                ],
              ),
            ),
            loading: () => const _LoadingPlaceholder(height: 140),
            error: (e, _) => _ErrorMessage(message: 'Could not load revenue'),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

int _metricCols(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w > 1200) return 4;
  if (w > 800) return 2;
  return 2;
}

class _MetricsGrid extends StatelessWidget {
  final BuildContext context;
  final List<Widget> children;

  const _MetricsGrid({required this.context, required this.children});

  @override
  Widget build(BuildContext _) {
    return GridView.count(
      crossAxisCount: _metricCols(context),
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: children,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade400,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final dynamic cat;
  const _CategoryRow({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                cat.categoryName,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Text(
            cat.amount.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  final String selectedPeriod;
  final WidgetRef ref;

  const _PeriodFilter({required this.selectedPeriod, required this.ref});

  @override
  Widget build(BuildContext context) {
    const periods = ['TODAY', 'WEEK', 'MONTH', 'YEAR'];
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final selected = selectedPeriod == period;
          return GestureDetector(
            onTap: () => ref.read(selectedPeriodProvider.notifier).state = period,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: selected ? const Color(0xFF111827) : Colors.grey.shade400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final double height;
  const _LoadingPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade300),
          const SizedBox(width: 6),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: Colors.red.shade300),
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends ConsumerWidget {
  final String period;
  const _RefreshButton({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.invalidate(dashboardMetricsProvider(period));
        ref.invalidate(dashboardStockProvider);
        ref.invalidate(dashboardRevenueProvider(period));
        ref.invalidate(dashboardExpenseProvider(period));
        ref.invalidate(dashboardTrendProvider(period));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Refresh',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
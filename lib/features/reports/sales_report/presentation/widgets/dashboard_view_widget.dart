import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sales_report_entities.dart';
import '../providers/sales_report_provider.dart';

class DashboardViewWidget extends ConsumerWidget {
  const DashboardViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(salesReportProvider).reportData;
    if (report == null) return const SizedBox.shrink();
    final s = report.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── KPI Row ───────────────────────────────────────────
        Row(children: [
          Expanded(
              child: _KpiTile(
            label: 'Revenue',
            value: _compact(s.totalRevenue),
            sub: '${s.totalOrders} orders',
            color: const Color(0xFF00C896),
            icon: Icons.trending_up_rounded,
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _KpiTile(
            label: 'Net',
            value: _compact(s.netRevenue),
            sub: 'After VAT',
            color: const Color(0xFF4C9EFF),
            icon: Icons.account_balance_wallet_rounded,
          )),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _KpiTile(
            label: 'Avg Order',
            value: _compact(s.averageOrderValue),
            sub: 'Per invoice',
            color: const Color(0xFFFF9F43),
            icon: Icons.receipt_long_rounded,
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _KpiTile(
            label: 'Customers',
            value: '${s.totalCustomers}',
            sub: 'Unique',
            color: const Color(0xFFA78BFA),
            icon: Icons.people_alt_rounded,
          )),
        ]),

        const SizedBox(height: 16),

        // ─── Status Strip ──────────────────────────────────────
        _SectionHeader(title: 'Order Status', icon: Icons.donut_small_rounded),
        const SizedBox(height: 8),
        _StatusStrip(s: s),

        const SizedBox(height: 16),

        // ─── Sales Trend Table ─────────────────────────────────
        if (report.groupedData != null && report.groupedData!.isNotEmpty) ...[
          _SectionHeader(
              title: 'Sales Trend', icon: Icons.stacked_line_chart_rounded),
          const SizedBox(height: 8),
          _TrendList(groupedData: report.groupedData!),
        ],
      ],
    );
  }

  static String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return NumberFormat('#,##0').format(v);
  }
}

// ─────────────────────────────────────────────
class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.4)),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1)),
          const SizedBox(height: 3),
          Text(sub,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _StatusStrip extends StatelessWidget {
  final dynamic s; // SalesSummary
  const _StatusStrip({required this.s});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatusItem('Pending', s.pendingOrders, s.pendingAmount,
          const Color(0xFFFF9F43), Icons.access_time_rounded),
      _StatusItem('Confirmed', s.confirmedOrders, s.confirmedAmount,
          const Color(0xFF4C9EFF), Icons.check_circle_outline_rounded),
      _StatusItem('Shipped', s.shippedOrders, null, const Color(0xFF6C63FF),
          Icons.local_shipping_rounded),
      _StatusItem('Delivered', s.deliveredOrders, s.deliveredAmount,
          const Color(0xFF00C896), Icons.check_circle_rounded),
      _StatusItem('Cancelled', s.cancelledOrders, s.cancelledAmount,
          const Color(0xFFFF5F5F), Icons.cancel_rounded),
      _StatusItem('Items Sold', s.totalItemsSold, null,
          const Color(0xFFA78BFA), Icons.inventory_2_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatusCell(item: items[i]),
    );
  }
}

class _StatusItem {
  final String label;
  final int count;
  final double? amount;
  final Color color;
  final IconData icon;
  const _StatusItem(
      this.label, this.count, this.amount, this.color, this.icon);
}

class _StatusCell extends StatelessWidget {
  final _StatusItem item;
  const _StatusCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 20),
          const SizedBox(height: 5),
          Text('${item.count}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: item.color)),
          Text(item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          if (item.amount != null)
            Text(
              _compact(item.amount!),
              style: TextStyle(
                  fontSize: 9,
                  color: item.color,
                  fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }

  static String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return NumberFormat('#,##0').format(v);
  }
}

// ─────────────────────────────────────────────
class _TrendList extends StatelessWidget {
  final List<GroupedSalesData> groupedData;
  const _TrendList({required this.groupedData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: groupedData.asMap().entries.map((e) {
          final g = e.value;
          final isLast = e.key == groupedData.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: const Color(0xFF4C9EFF),
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(g.groupLabel,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat('#,##0.00').format(g.totalRevenue),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00C896)),
                        ),
                        Text(
                          '${g.orderCount} orders · avg ${NumberFormat('#,##0').format(g.averageOrderValue)}',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, color: Colors.grey.shade100, indent: 30),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey.shade600),
      const SizedBox(width: 6),
      Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              letterSpacing: 0.2)),
    ]);
  }
}
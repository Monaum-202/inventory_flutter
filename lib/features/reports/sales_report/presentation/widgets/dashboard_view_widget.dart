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

    return Column(
      children: [
        // ─── Summary Cards ─────────────────────────────────────
        LayoutBuilder(builder: (context, c) {
          final crossAxis = c.maxWidth > 800 ? 4 : 2;
          return GridView.count(
            crossAxisCount: crossAxis,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _SummaryCard(
                title: 'Total Revenue',
                value: _currency(report.summary.totalRevenue),
                subtitle: '${report.summary.totalOrders} orders',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              _SummaryCard(
                title: 'Net Revenue',
                value: _currency(report.summary.netRevenue),
                subtitle: 'After discount & VAT',
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
              ),
              _SummaryCard(
                title: 'Avg Order Value',
                value: _currency(report.summary.averageOrderValue),
                subtitle: 'Per order',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
              _SummaryCard(
                title: 'Total Customers',
                value: '${report.summary.totalCustomers}',
                subtitle: 'Unique customers',
                icon: Icons.people,
                color: Colors.grey,
              ),
            ],
          );
        }),
        const SizedBox(height: 16),

        // ─── Status Breakdown ──────────────────────────────────
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.bar_chart, size: 18),
                  const SizedBox(width: 8),
                  Text('Order Status Breakdown',
                      style: Theme.of(context).textTheme.titleMedium),
                ]),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(builder: (context, c) {
                  final crossAxis = c.maxWidth > 700 ? 6 : 3;
                  final s = report.summary;
                  return GridView.count(
                    crossAxisCount: crossAxis,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _StatusCard(
                          label: 'Pending',
                          count: s.pendingOrders,
                          amount: s.pendingAmount,
                          icon: Icons.access_time,
                          color: Colors.orange),
                      _StatusCard(
                          label: 'Confirmed',
                          count: s.confirmedOrders,
                          amount: s.confirmedAmount,
                          icon: Icons.check_circle_outline,
                          color: Colors.blue),
                      _StatusCard(
                          label: 'Shipped',
                          count: s.shippedOrders,
                          icon: Icons.local_shipping,
                          color: Colors.indigo),
                      _StatusCard(
                          label: 'Delivered',
                          count: s.deliveredOrders,
                          amount: s.deliveredAmount,
                          icon: Icons.check_circle,
                          color: Colors.green),
                      _StatusCard(
                          label: 'Cancelled',
                          count: s.cancelledOrders,
                          amount: s.cancelledAmount,
                          icon: Icons.cancel,
                          color: Colors.red),
                      _StatusCard(
                          label: 'Items Sold',
                          count: s.totalItemsSold,
                          icon: Icons.inventory_2,
                          color: Colors.brown),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── Grouped Data Table ────────────────────────────────
        if (report.groupedData != null && report.groupedData!.isNotEmpty)
          _GroupedDataTable(groupedData: report.groupedData!),
      ],
    );
  }

  static String _currency(double v) =>
      NumberFormat('#,##0.00', 'en_US').format(v);
}

// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 22),
            ]),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final double? amount;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.count,
    this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text('$count',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          if (amount != null)
            Text(
              NumberFormat('#,##0.00').format(amount),
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _GroupedDataTable extends StatelessWidget {
  final List<GroupedSalesData> groupedData;
  const _GroupedDataTable({required this.groupedData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Icon(Icons.calendar_month, size: 18),
              const SizedBox(width: 8),
              Text('Sales Trend',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(Colors.grey.shade50),
              columns: const [
                DataColumn(label: Text('Period')),
                DataColumn(label: Text('Orders'), numeric: true),
                DataColumn(label: Text('Revenue'), numeric: true),
                DataColumn(label: Text('Avg Order'), numeric: true),
                DataColumn(label: Text('Items'), numeric: true),
              ],
              rows: groupedData.map((g) {
                return DataRow(cells: [
                  DataCell(Text(g.groupLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text('${g.orderCount}')),
                  DataCell(Text(
                    NumberFormat('#,##0.00').format(g.totalRevenue),
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600),
                  )),
                  DataCell(Text(NumberFormat('#,##0.00')
                      .format(g.averageOrderValue))),
                  DataCell(Text(g.totalItems != null
                      ? '${g.totalItems}'
                      : 'N/A')),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
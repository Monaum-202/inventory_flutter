import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/sales_report_provider.dart';

// ═════════════════════════════════════════════
// Products View
// ═════════════════════════════════════════════

class ProductsViewWidget extends ConsumerWidget {
  const ProductsViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pp = ref.watch(salesReportProvider).productPerformance;
    if (pp == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.inventory_2_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text('Top Selling Products',
                      style: Theme.of(context).textTheme.titleMedium),
                ]),
                Wrap(spacing: 16, children: [
                  _Stat(
                      label: 'Products',
                      value: '${pp.summary.totalUniqueProducts}'),
                  _Stat(
                      label: 'Items Sold',
                      value: '${pp.summary.totalQuantitySold}'),
                  _Stat(
                      label: 'Revenue',
                      value: _currency(pp.summary.totalRevenue)),
                ]),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(Colors.grey.shade50),
              columns: const [
                DataColumn(label: Text('Rank')),
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Qty Sold'), numeric: true),
                DataColumn(label: Text('Revenue'), numeric: true),
                DataColumn(label: Text('Avg Price'), numeric: true),
                DataColumn(label: Text('Orders'), numeric: true),
                DataColumn(label: Text('% of Total'), numeric: true),
              ],
              rows: pp.topProducts.isEmpty
                  ? [
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: 500,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                const Text('No products found'),
                              ],
                            ),
                          ),
                        )),
                        ...List.generate(6, (_) => const DataCell(SizedBox())),
                      ]),
                    ]
                  : pp.topProducts.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      return DataRow(cells: [
                        DataCell(_RankBadge(rank: i + 1)),
                        DataCell(Text(p.itemName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600))),
                        DataCell(_ColorBadge(
                            text: '${p.totalQuantitySold}',
                            color: Colors.blue)),
                        DataCell(Text(
                          _currency(p.totalRevenue),
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        )),
                        DataCell(Text(_currency(p.averageUnitPrice))),
                        DataCell(Text('${p.orderCount}')),
                        DataCell(_ColorBadge(
                          text:
                              '${p.revenuePercentage.toStringAsFixed(1)}%',
                          color: Colors.grey.shade600,
                        )),
                      ]);
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _currency(double v) =>
      NumberFormat('#,##0.00', 'en_US').format(v);
}

// ═════════════════════════════════════════════
// Customers View
// ═════════════════════════════════════════════

class CustomersViewWidget extends ConsumerWidget {
  const CustomersViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ca = ref.watch(salesReportProvider).customerAnalytics;
    if (ca == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.people_outline, size: 18),
                  const SizedBox(width: 8),
                  Text('Top Customers',
                      style: Theme.of(context).textTheme.titleMedium),
                ]),
                _Stat(
                    label: 'Total Customers',
                    value: '${ca.summary.totalCustomers}'),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(Colors.grey.shade50),
              columns: const [
                DataColumn(label: Text('Rank')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Company')),
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Orders'), numeric: true),
                DataColumn(label: Text('Total Spent'), numeric: true),
                DataColumn(label: Text('Avg Order'), numeric: true),
                DataColumn(label: Text('Last Order')),
                DataColumn(label: Text('Days Since'), numeric: true),
              ],
              rows: ca.topCustomers.isEmpty
                  ? [
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: 600,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                const Text('No customers found'),
                              ],
                            ),
                          ),
                        )),
                        ...List.generate(8, (_) => const DataCell(SizedBox())),
                      ]),
                    ]
                  : ca.topCustomers.asMap().entries.map((entry) {
                      final i = entry.key;
                      final c = entry.value;
                      return DataRow(cells: [
                        DataCell(_RankBadge(rank: i + 1)),
                        DataCell(Text(c.customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600))),
                        DataCell(Text(c.companyName ?? '-',
                            style: const TextStyle(fontSize: 12))),
                        DataCell(Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.phone,
                                style: const TextStyle(fontSize: 12)),
                            if (c.email != null)
                              Text(c.email!,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600)),
                          ],
                        )),
                        DataCell(_ColorBadge(
                            text: '${c.totalOrders}',
                            color: Colors.blue)),
                        DataCell(Text(
                          _currency(c.totalSpent),
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        )),
                        DataCell(
                            Text(_currency(c.averageOrderValue))),
                        DataCell(Text(_fmtDate(c.lastOrderDate))),
                        DataCell(_DaysBadge(days: c.daysSinceLastOrder)),
                      ]);
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _currency(double v) =>
      NumberFormat('#,##0.00', 'en_US').format(v);

  static String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd/MM/yyyy').format(dt) : d;
  }
}

// ─────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(
              text: value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 13)),
          TextSpan(text: ' $label'),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('$rank',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _ColorBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _ColorBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _DaysBadge extends StatelessWidget {
  final int days;
  const _DaysBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    final color = days <= 30
        ? Colors.green
        : days <= 90
            ? Colors.orange
            : Colors.red;
    return _ColorBadge(text: '$days days', color: color);
  }
}
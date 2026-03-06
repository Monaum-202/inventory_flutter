import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sales_report_entities.dart';
import '../providers/sales_report_provider.dart';

class SalesTableWidget extends ConsumerWidget {
  const SalesTableWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesReportProvider);
    final notifier = ref.read(salesReportProvider.notifier);
    final report = state.reportData;

    if (report == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // ─── Table ────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(Colors.grey.shade50),
              columnSpacing: 16,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 64,
              columns: const [
                DataColumn(label: Text('Invoice')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Company')),
                DataColumn(label: Text('Items'), numeric: true),
                DataColumn(label: Text('Subtotal'), numeric: true),
                DataColumn(label: Text('Discount'), numeric: true),
                DataColumn(label: Text('VAT'), numeric: true),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Paid'), numeric: true),
                DataColumn(label: Text('Due'), numeric: true),
                DataColumn(label: Text('Status')),
              ],
              rows: report.salesDetails.isEmpty
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
                                const Text('No sales found'),
                              ],
                            ),
                          ),
                        )),
                        ...List.generate(11, (_) => const DataCell(SizedBox())),
                      ])
                    ]
                  : report.salesDetails
                      .map((sale) => _buildRow(sale))
                      .toList(),
            ),
          ),

          // ─── Pagination ────────────────────────────────────────
          if (report.salesDetails.isNotEmpty)
            _PaginationBar(
              pagination: report.pagination,
              pageSize: state.pageSize,
              currentPage: state.currentPage,
              onPageChanged: notifier.goToPage,
              onPreviousPage: notifier.previousPage,
              onNextPage: notifier.nextPage,
              onPageSizeChanged: notifier.changePageSize,
            ),
        ],
      ),
    );
  }

  DataRow _buildRow(SaleDetail sale) {
    return DataRow(cells: [
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sale.invoiceNo,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(sale.phone,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      )),
      DataCell(Text(_fmtDate(sale.sellDate))),
      DataCell(Text(sale.customerName)),
      DataCell(Text(sale.companyName ?? '-',
          style: const TextStyle(fontSize: 12))),
      DataCell(_Badge(text: '${sale.totalItems}', color: Colors.grey)),
      DataCell(Text(_currency(sale.subtotal))),
      DataCell(Text(_currency(sale.discount),
          style: const TextStyle(color: Colors.red))),
      DataCell(Text(_currency(sale.vat),
          style: const TextStyle(color: Colors.green))),
      DataCell(Text(_currency(sale.totalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(_currency(sale.paidAmount),
          style: const TextStyle(color: Colors.green))),
      DataCell(Text(
        _currency(sale.dueAmount),
        style: TextStyle(
            color: sale.dueAmount > 0 ? Colors.red : Colors.black87),
      )),
      DataCell(_StatusBadge(status: sale.status)),
    ]);
  }

  static String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd/MM/yyyy').format(dt) : d;
  }

  static String _currency(double v) =>
      NumberFormat('#,##0.00', 'en_US').format(v);
}

// ─────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final SalesPagination pagination;
  final int pageSize;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final ValueChanged<int> onPageSizeChanged;

  const _PaginationBar({
    required this.pagination,
    required this.pageSize,
    required this.currentPage,
    required this.onPageChanged,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final start = currentPage * pagination.pageSize + 1;
    final end = ((currentPage + 1) * pagination.pageSize)
        .clamp(0, pagination.totalElements);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text('Rows:', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: pageSize,
            isDense: true,
            underline: const SizedBox(),
            items: [10, 20, 50, 100]
                .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                .toList(),
            onChanged: (v) => v != null ? onPageSizeChanged(v) : null,
          ),
          const SizedBox(width: 16),
          Text(
            '$start–$end of ${pagination.totalElements}',
            style: const TextStyle(fontSize: 13),
          ),
          const Spacer(),
          // Page number buttons
          IconButton(
            onPressed: pagination.hasPrevious ? onPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            padding: EdgeInsets.zero,
          ),
          ..._pageNumbers(pagination).map((p) {
            final isActive = p == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: isActive
                  ? FilledButton(
                      onPressed: () => onPageChanged(p),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('${p + 1}'),
                    )
                  : OutlinedButton(
                      onPressed: () => onPageChanged(p),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('${p + 1}'),
                    ),
            );
          }),
          IconButton(
            onPressed: pagination.hasNext ? onNextPage : null,
            icon: const Icon(Icons.chevron_right),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  List<int> _pageNumbers(SalesPagination p) {
    const maxPages = 5;
    final total = p.totalPages;
    var start = (currentPage - 2).clamp(0, total - 1);
    var end = (start + maxPages - 1).clamp(0, total - 1);
    if (end - start < maxPages - 1) {
      start = (end - maxPages + 1).clamp(0, total - 1);
    }
    return List.generate(end - start + 1, (i) => start + i);
  }
}

// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _config(status.toUpperCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(status,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  (Color, IconData) _config(String s) => switch (s) {
        'DELIVERED' => (Colors.green, Icons.check_circle),
        'CONFIRMED' => (Colors.blue, Icons.check_circle_outline),
        'SHIPPED' => (Colors.indigo, Icons.local_shipping),
        'PENDING' => (Colors.orange, Icons.access_time),
        'CANCELLED' => (Colors.red, Icons.cancel),
        'PROCESSING' => (Colors.purple, Icons.autorenew),
        _ => (Colors.grey, Icons.circle),
      };
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
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

    if (report.salesDetails.isEmpty) {
      return _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Count Banner ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4C9EFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${report.pagination.totalElements} invoices',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C9EFF)),
              ),
            ),
          ]),
        ),

        // ─── Sale Cards ────────────────────────────────────────
        ...report.salesDetails.map((sale) => _SaleCard(sale: sale)),

        // ─── Pagination ────────────────────────────────────────
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
    );
  }
}

// ─────────────────────────────────────────────
class _SaleCard extends StatelessWidget {
  final SaleDetail sale;
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Invoice + Status
              Row(children: [
                Text(sale.invoiceNo,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4C9EFF))),
                const Spacer(),
                _StatusBadge(status: sale.status),
              ]),

              const SizedBox(height: 8),

              // Row 2: Customer + Date
              Row(children: [
                const Icon(Icons.person_rounded,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(sale.customerName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(_fmtDate(sale.sellDate),
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ]),

              if ((sale.companyName ?? '').isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.business_rounded,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(sale.companyName!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ]),
              ],

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Row 3: Financial summary
              Row(children: [
                _FinItem(
                    label: 'Total',
                    value: _cur(sale.totalAmount),
                    color: Colors.black87,
                    bold: true),
                const SizedBox(width: 12),
                _FinItem(
                    label: 'Paid',
                    value: _cur(sale.paidAmount),
                    color: const Color(0xFF00C896)),
                const SizedBox(width: 12),
                if (sale.dueAmount > 0)
                  _FinItem(
                      label: 'Due',
                      value: _cur(sale.dueAmount),
                      color: const Color(0xFFFF5F5F)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${sale.totalItems} items',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaleDetailSheet(sale: sale),
    );
  }

  static String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yy').format(dt) : d;
  }

  static String _cur(double v) => NumberFormat('#,##0.00').format(v);
}

// ─────────────────────────────────────────────
class _SaleDetailSheet extends StatelessWidget {
  final SaleDetail sale;
  const _SaleDetailSheet({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(children: [
            Text(sale.invoiceNo,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            _StatusBadge(status: sale.status),
          ]),
          const SizedBox(height: 4),
          Text(
            '${sale.customerName}${(sale.companyName ?? '').isNotEmpty ? ' · ${sale.companyName}' : ''}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _Row('Date', _fmtDate(sale.sellDate)),
          _Row('Phone', sale.phone),
          const Divider(height: 24),
          _Row('Subtotal', _cur(sale.subtotal)),
          _Row('Discount', '-${_cur(sale.discount)}',
              color: const Color(0xFFFF5F5F)),
          _Row('VAT', '+${_cur(sale.vat)}',
              color: const Color(0xFFFF9F43)),
          const Divider(height: 24),
          _Row('Total', _cur(sale.totalAmount), bold: true),
          _Row('Paid', _cur(sale.paidAmount),
              color: const Color(0xFF00C896)),
          if (sale.dueAmount > 0)
            _Row('Due', _cur(sale.dueAmount),
                color: const Color(0xFFFF5F5F), bold: true),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _Row(String label, String val,
      {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(label,
            style:
                TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        const Spacer(),
        Text(val,
            style: TextStyle(
                fontSize: 13,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? Colors.black87)),
      ]),
    );
  }

  static String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yyyy').format(dt) : d;
  }

  static String _cur(double v) => NumberFormat('#,##0.00').format(v);
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
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          // Rows per page
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: pageSize,
                isDense: true,
                items: [10, 20, 50, 100]
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text('$v rows')))
                    .toList(),
                onChanged: (v) => v != null ? onPageSizeChanged(v) : null,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ),
          ),

          const SizedBox(width: 10),
          Text('$start–$end of ${pagination.totalElements}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),

          const Spacer(),

          // Prev
          _NavBtn(
              icon: Icons.chevron_left_rounded,
              onTap: pagination.hasPrevious ? onPreviousPage : null),

          // Page numbers
          ..._pages(pagination).map((p) {
            final active = p == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () => onPageChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF4C9EFF)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${p + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white
                              : Colors.grey.shade700)),
                ),
              ),
            );
          }),

          // Next
          _NavBtn(
              icon: Icons.chevron_right_rounded,
              onTap: pagination.hasNext ? onNextPage : null),
        ],
      ),
    );
  }

  List<int> _pages(SalesPagination p) {
    const maxP = 5;
    final total = p.totalPages;
    var s = (currentPage - 2).clamp(0, total - 1);
    var e = (s + maxP - 1).clamp(0, total - 1);
    if (e - s < maxP - 1) s = (e - maxP + 1).clamp(0, total - 1);
    return List.generate(e - s + 1, (i) => s + i);
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color:
                enabled ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _FinItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _FinItem({
    required this.label,
    required this.value,
    this.color = Colors.black87,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 9.5, color: Colors.grey.shade400)),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w600,
                color: color)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _cfg(status.toUpperCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 4),
        Text(status,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  (Color, IconData) _cfg(String s) => switch (s) {
        'DELIVERED' => (const Color(0xFF00C896), Icons.check_circle_rounded),
        'CONFIRMED' => (const Color(0xFF4C9EFF), Icons.check_circle_outline_rounded),
        'SHIPPED' => (const Color(0xFF6C63FF), Icons.local_shipping_rounded),
        'PENDING' => (const Color(0xFFFF9F43), Icons.access_time_rounded),
        'CANCELLED' => (const Color(0xFFFF5F5F), Icons.cancel_rounded),
        'PROCESSING' => (const Color(0xFFA78BFA), Icons.autorenew_rounded),
        _ => (Colors.grey, Icons.circle),
      };
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          Icon(Icons.receipt_long_rounded,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No sales found',
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Try adjusting your filters',
              style: TextStyle(
                  color: Colors.grey.shade300, fontSize: 12)),
        ]),
      ),
    );
  }
}
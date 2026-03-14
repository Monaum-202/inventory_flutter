// ============================================================
//  sales_table_widget.dart  —  table + pagination only
//  Columns: #  Invoice  Customer  Date  Total/Due  Status
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/core/widgets/rg_tokens.dart';

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
    if (report.salesDetails.isEmpty) return const _EmptyState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Table card ─────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: RgColors.surface,
            borderRadius: RgRadius.lgAll,
            border: Border.all(color: RgColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toolbar
              _TableToolbar(
                totalElements: report.pagination.totalElements,
                pageSize: state.pageSize,
                onPageSizeChanged: notifier.changePageSize,
              ),

              // Column headers
              const _TableHeader(),

              // Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.salesDetails.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: RgColors.border),
                itemBuilder: (_, i) {
                  final row = report.salesDetails[i];
                  final serial = state.currentPage * state.pageSize + i + 1;
                  return _TableRow(
                    row: row,
                    serial: serial,
                    onTap: () => _showDetail(context, row),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Pagination ─────────────────────────────────────────
        if (report.pagination.totalPages > 1)
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

  void _showDetail(BuildContext context, SaleDetail sale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetailSheet(sale: sale),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Toolbar
// ─────────────────────────────────────────────────────────────
class _TableToolbar extends StatelessWidget {
  final int totalElements;
  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;

  const _TableToolbar({
    required this.totalElements,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RgColors.border)),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: RgColors.muted,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: NumberFormat('#,##0').format(totalElements),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: RgColors.text,
                  ),
                ),
                const TextSpan(text: ' records'),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'Rows ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: RgColors.muted,
            ),
          ),
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: RgColors.bg,
              borderRadius: RgRadius.smAll,
              border: Border.all(color: RgColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: [25, 50, 100, 200].contains(pageSize) ? pageSize : 25,
                isDense: true,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: RgColors.text,
                ),
                items: [25, 50, 100, 200]
                    .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                    .toList(),
                onChanged: (v) => v != null ? onPageSizeChanged(v) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Column header
// ─────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RgColors.tableBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: const Row(
        children: [
          // Invoice + Customer (combined)
          Expanded(flex: 5, child: _Th('Invoice / Customer')),
          // Date
          Expanded(flex: 3, child: _Th('Date')),
          // Total
          Expanded(flex: 3, child: _Th('Total', right: true)),
          // Status
          Expanded(flex: 3, child: _Th('Status', center: true)),
        ],
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String text;
  final bool right;
  final bool center;
  const _Th(this.text, {this.right = false, this.center = false});

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    textAlign: right
        ? TextAlign.right
        : center
        ? TextAlign.center
        : TextAlign.left,
    style: const TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: RgColors.muted,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Data row
// ─────────────────────────────────────────────────────────────
class _TableRow extends StatelessWidget {
  final SaleDetail row;
  final int serial;
  final VoidCallback onTap;

  const _TableRow({
    required this.row,
    required this.serial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice No + Customer (stacked, flex 5)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: RgColors.primary.withOpacity(0.08),
                      borderRadius: RgRadius.smAll,
                    ),
                    child: Text(
                      row.invoiceNo,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: RgColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Customer name
                  Text(
                    row.customerName,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: RgColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Date (flex 3)
            Expanded(
              flex: 3,
              child: Text(
                _fmtDate(row.sellDate),
                style: const TextStyle(fontSize: 10.5, color: RgColors.muted),
              ),
            ),
            const SizedBox(width: 4),

            // Total + Due (flex 3)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _cur(row.totalAmount),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: RgColors.text,
                    ),
                  ),
                  if (row.dueAmount > 0)
                    Text(
                      '−${_cur(row.dueAmount)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10,
                        color: RgColors.danger,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Status (flex 3)
            Expanded(
              flex: 3,
              child: Center(child: _StatusBadge(status: row.status)),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yy').format(dt) : d;
  }

  static String _cur(double v) => NumberFormat('#,##0.00').format(v);
}

// ─────────────────────────────────────────────────────────────
// Detail bottom sheet
// ─────────────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final SaleDetail sale;
  const _DetailSheet({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RgColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: RgColors.primary, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: RgColors.border,
                borderRadius: RgRadius.fullAll,
              ),
            ),
          ),

          // Invoice + status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RgColors.primary.withOpacity(0.08),
                  borderRadius: RgRadius.smAll,
                ),
                child: Text(
                  sale.invoiceNo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: RgColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              _StatusBadge(status: sale.status, large: true),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            '${sale.customerName}'
            '${(sale.companyName ?? '').isNotEmpty ? ' · ${sale.companyName}' : ''}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (sale.phone.isNotEmpty)
            Text(
              sale.phone,
              style: const TextStyle(fontSize: 12, color: RgColors.muted),
            ),

          const SizedBox(height: 16),
          _Row('Sell Date', _fmtDate(sale.sellDate)),
          if (sale.deliveryDate != null)
            _Row('Delivery', _fmtDate(sale.deliveryDate!)),
          _Row('Items', '${sale.totalItems}'),

          const Divider(height: 24, color: RgColors.border),
          _Row('Sub Total', _cur(sale.subtotal)),
          if (sale.discount > 0)
            _Row('Discount', '−${_cur(sale.discount)}', color: RgColors.danger),
          if (sale.vat > 0)
            _Row('VAT', '+${_cur(sale.vat)}', color: RgColors.warning),

          const Divider(height: 24, color: RgColors.border),
          _Row('Total', _cur(sale.totalAmount), bold: true),
          _Row(
            'Paid',
            _cur(sale.paidAmount),
            color: RgColors.success,
            bold: true,
          ),
          if (sale.dueAmount > 0)
            _Row(
              'Due',
              _cur(sale.dueAmount),
              color: RgColors.danger,
              bold: true,
            ),
        ],
      ),
    );
  }

  Widget _Row(String label, String value, {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: RgColors.muted),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? RgColors.text,
              ),
            ),
          ],
        ),
      );

  static String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yyyy').format(dt) : d;
  }

  static String _cur(double v) => NumberFormat('#,##0.00').format(v);
}

// ─────────────────────────────────────────────────────────────
// Pagination
// ─────────────────────────────────────────────────────────────
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
    final end = ((currentPage + 1) * pagination.pageSize).clamp(
      0,
      pagination.totalElements,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: RgColors.surface,
        borderRadius: RgRadius.lgAll,
        border: Border.all(color: RgColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Record range info
          Flexible(
            child: Text(
              '$start–$end of ${pagination.totalElements}',
              style: const TextStyle(fontSize: 11, color: RgColors.muted),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          // Prev
          _PgBtn(
            icon: Icons.chevron_left_rounded,
            onTap: pagination.hasPrevious ? onPreviousPage : null,
          ),

          // Page numbers — max 3 visible
          ..._visiblePages().map((p) {
            final active = p == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () => onPageChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? RgColors.primary : Colors.transparent,
                    borderRadius: RgRadius.smAll,
                    border: Border.all(
                      color: active ? RgColors.primary : RgColors.border,
                    ),
                  ),
                  child: Text(
                    '${p + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : RgColors.muted,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Next
          _PgBtn(
            icon: Icons.chevron_right_rounded,
            onTap: pagination.hasNext ? onNextPage : null,
          ),

          const SizedBox(width: 6),

          // Page x of y
          Text(
            '${currentPage + 1}/${pagination.totalPages}',
            style: const TextStyle(fontSize: 10, color: RgColors.muted),
          ),
        ],
      ),
    );
  }

  List<int> _visiblePages() {
    const max = 3; // keep it tight on mobile
    final total = pagination.totalPages;
    if (total == 0) return [];
    var s = (currentPage - 1).clamp(0, total - 1);
    var e = (s + max - 1).clamp(0, total - 1);
    if (e - s < max - 1) s = (e - max + 1).clamp(0, total - 1);
    return List.generate(e - s + 1, (i) => s + i);
  }
}

class _PgBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  const _PgBtn({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: RgRadius.smAll,
          border: Border.all(color: RgColors.border),
        ),
        child: icon != null
            ? Icon(
                icon,
                size: 16,
                color: enabled ? RgColors.muted : RgColors.border,
              )
            : Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: enabled ? RgColors.muted : RgColors.border,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool large;
  const _StatusBadge({required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final (fg, bg, bdr) = _cfg(status.toUpperCase());
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 8 : 5,
        vertical: large ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: RgRadius.fullAll,
        border: Border.all(color: bdr),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: large ? 11 : 9,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  static (Color, Color, Color) _cfg(String s) => switch (s) {
    'PAID' || 'DELIVERED' => (
      const Color(0xFF166534),
      RgColors.successBg,
      const Color(0xFFBBF7D0),
    ),
    'CONFIRMED' => (
      RgColors.primary,
      const Color(0xFFEFF6FF),
      const Color(0xFFBFDBFE),
    ),
    'SHIPPED' => (
      const Color(0xFF155E75),
      RgColors.infoBg,
      const Color(0xFFA5F3FC),
    ),
    'PENDING' || 'PROCESSING' => (
      const Color(0xFF92400E),
      RgColors.warningBg,
      const Color(0xFFFDE68A),
    ),
    'CANCELLED' => (
      const Color(0xFF991B1B),
      RgColors.dangerBg,
      const Color(0xFFFECACA),
    ),
    'PARTIAL' => (
      const Color(0xFF155E75),
      RgColors.infoBg,
      const Color(0xFFA5F3FC),
    ),
    _ => (RgColors.muted, RgColors.bg, RgColors.border),
  };
}

// ─────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56),
        child: Column(
          children: const [
            Icon(Icons.receipt_long_rounded, size: 52, color: RgColors.border),
            SizedBox(height: 14),
            Text(
              'No sales records found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: RgColors.muted,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 12, color: RgColors.border),
            ),
          ],
        ),
      ),
    );
  }
}

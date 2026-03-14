// ============================================================
//  filter_section_widget.dart  —  date · status · customer · export
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/core/widgets/rg_tokens.dart';
import 'package:inventory_app/core/utils/pdf_download_helper.dart';

import '../providers/sales_report_provider.dart';

class FilterSectionWidget extends ConsumerStatefulWidget {
  const FilterSectionWidget({super.key});

  @override
  ConsumerState<FilterSectionWidget> createState() =>
      _FilterSectionWidgetState();
}

class _FilterSectionWidgetState extends ConsumerState<FilterSectionWidget> {
  final _customerCtrl = TextEditingController();
  String? _status;

  static const _statusOptions = [
    MapEntry('', 'All'),
    MapEntry('PENDING', 'Pending'),
    MapEntry('CONFIRMED', 'Confirmed'),
    MapEntry('SHIPPED', 'Shipped'),
    MapEntry('DELIVERED', 'Delivered'),
    MapEntry('CANCELLED', 'Cancelled'),
    MapEntry('PROCESSING', 'Processing'),
  ];

  static final _quickRanges = _buildQuickRanges();

  static List<_QR> _buildQuickRanges() {
    final f = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    return [
      _QR('Today', f.format(now), f.format(now)),
      _QR(
        'This Week',
        f.format(now.subtract(Duration(days: now.weekday - 1))),
        f.format(now),
      ),
      _QR(
        'This Month',
        f.format(DateTime(now.year, now.month, 1)),
        f.format(now),
      ),
      _QR(
        'Last Month',
        f.format(DateTime(now.year, now.month - 1, 1)),
        f.format(DateTime(now.year, now.month, 0)),
      ),
      _QR(
        'Last 7d',
        f.format(now.subtract(const Duration(days: 6))),
        f.format(now),
      ),
      _QR(
        'Last 30d',
        f.format(now.subtract(const Duration(days: 29))),
        f.format(now),
      ),
      _QR('This Year', f.format(DateTime(now.year, 1, 1)), f.format(now)),
    ];
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    super.dispose();
  }

  bool _hasFilters(dynamic f) =>
      (_status ?? '').isNotEmpty || (f.customerName ?? '').isNotEmpty;

  String _dateLabel(String? s, String? e) {
    if (s == null && e == null) return 'Select date range';
    final fmt = DateFormat('d MMM y');
    return '${s != null ? fmt.format(DateTime.parse(s)) : '—'}'
        ' → '
        '${e != null ? fmt.format(DateTime.parse(e)) : '—'}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesReportProvider);
    final notifier = ref.read(salesReportProvider.notifier);
    final filter = state.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main filter card ───────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: RgColors.surface,
            borderRadius: RgRadius.lgAll,
            border: Border.all(color: RgColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: RgRadius.lgAll,
            border: const Border(
              top: BorderSide(color: RgColors.primary, width: 3),
            ),
          ),
          child: Column(
            children: [
              // ── Date row + action buttons ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: RgColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dateLabel(filter.startDate, filter.endDate),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: RgColors.text,
                        ),
                      ),
                    ),

                    // Filter sheet button
                    _IconBtn(
                      icon: Icons.tune_rounded,
                      onTap: () => _openSheet(context),
                      hasBadge: _hasFilters(filter),
                    ),
                    const SizedBox(width: 6),

                    // Reset
                    _IconBtn(
                      icon: Icons.refresh_rounded,
                      color: RgColors.muted,
                      onTap: () {
                        _customerCtrl.clear();
                        setState(() => _status = null);
                        notifier.resetFilters();
                      },
                    ),
                    const SizedBox(width: 6),

                    // PDF export
                    _IconBtn(
                      icon: Icons.picture_as_pdf_rounded,
                      color: RgColors.danger,
                      loading: state.isExporting,
                      onTap: state.isExporting
                          ? null
                          : () => notifier.exportReport((bytes) async {
                              try {
                                final filename =
                                    'Sales_Report_${state.filter.startDate}_${state.filter.endDate}.pdf';
                                await PdfDownloadHelper.saveAndOpen(
                                  bytes,
                                  filename,
                                );
                              } catch (e) {
                                _snack(context, 'Failed to open PDF: $e');
                              }
                            }),
                    ),
                    const SizedBox(width: 6),

                    // Excel export
                    _IconBtn(
                      icon: Icons.table_chart_rounded,
                      color: RgColors.success,
                      onTap: state.isExporting
                          ? null
                          : () => notifier.exportReport(
                              (_) => _snack(context, 'Excel ready'),
                            ),
                      loading: state.isExporting,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: RgColors.border),

              // ── Quick range chips ──────────────────────────
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  itemCount: _quickRanges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final r = _quickRanges[i];
                    final active =
                        filter.startDate == r.start && filter.endDate == r.end;
                    return GestureDetector(
                      onTap: () => notifier.applyQuickRange(r.start, r.end),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: active ? RgColors.primary : RgColors.bg,
                          borderRadius: RgRadius.fullAll,
                          border: Border.all(
                            color: active ? RgColors.primary : RgColors.border,
                          ),
                        ),
                        child: Text(
                          r.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : RgColors.muted,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Active filter tags ─────────────────────────────────
        if (_hasFilters(filter)) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if ((_status ?? '').isNotEmpty)
                _Tag(
                  label: _status!,
                  onRemove: () {
                    setState(() => _status = null);
                    notifier.updateFilter(filter.copyWith(status: ''));
                  },
                ),
              if ((filter.customerName ?? '').isNotEmpty)
                _Tag(
                  label: filter.customerName!,
                  onRemove: () {
                    _customerCtrl.clear();
                    notifier.updateFilter(filter.copyWith(customerName: ''));
                  },
                ),
            ],
          ),
        ],

        // ── Error banner ───────────────────────────────────────
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          _ErrorBanner(
            message: state.errorMessage!,
            onDismiss: notifier.clearError,
          ),
        ],
      ],
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        customerCtrl: _customerCtrl,
        status: _status,
        statusOptions: _statusOptions,
        onStatusChanged: (v) => setState(() => _status = v),
      ),
    );
  }

  static void _snack(BuildContext ctx, String msg) =>
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
}

// ─────────────────────────────────────────────────────────────
// Filter bottom sheet  (date · status · customer only)
// ─────────────────────────────────────────────────────────────
class _FilterSheet extends ConsumerStatefulWidget {
  final TextEditingController customerCtrl;
  final String? status;
  final List<MapEntry<String, String>> statusOptions;
  final ValueChanged<String?> onStatusChanged;

  const _FilterSheet({
    required this.customerCtrl,
    required this.status,
    required this.statusOptions,
    required this.onStatusChanged,
  });

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late String? _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(salesReportProvider.notifier);
    final filter = ref.read(salesReportProvider).filter;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: RgColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: RgColors.primary, width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RgColors.border,
              borderRadius: RgRadius.fullAll,
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: RgColors.text,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.customerCtrl.clear();
                    setState(() => _status = null);
                    widget.onStatusChanged(null);
                    notifier.resetFilters();
                  },
                  child: const Text(
                    'Reset all',
                    style: TextStyle(
                      color: RgColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: RgColors.border),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date pickers
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Start Date',
                          value: filter.startDate,
                          onChanged: (d) => notifier.updateFilter(
                            filter.copyWith(startDate: d),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'End Date',
                          value: filter.endDate,
                          onChanged: (d) => notifier.updateFilter(
                            filter.copyWith(endDate: d),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Customer search
                  _Label('Customer'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: widget.customerCtrl,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name…',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: RgColors.muted,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: RgColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: RgRadius.smAll,
                        borderSide: const BorderSide(color: RgColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: RgRadius.smAll,
                        borderSide: const BorderSide(color: RgColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: RgRadius.smAll,
                        borderSide: const BorderSide(
                          color: RgColors.primary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: RgColors.muted,
                      ),
                    ),
                    onChanged: (v) =>
                        notifier.updateFilter(filter.copyWith(customerName: v)),
                  ),
                  const SizedBox(height: 16),

                  // Status chips
                  _Label('Status'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.statusOptions.map((e) {
                      final sel = (_status ?? '') == e.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _status = e.key);
                          widget.onStatusChanged(e.key);
                          notifier.updateFilter(filter.copyWith(status: e.key));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? RgColors.primary : RgColors.bg,
                            borderRadius: RgRadius.fullAll,
                            border: Border.all(
                              color: sel ? RgColors.primary : RgColors.border,
                            ),
                          ),
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : RgColors.muted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Apply
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: RgColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: RgRadius.smAll),
                ),
                onPressed: () {
                  notifier.applyFilters();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small shared widgets
// ─────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.7,
      color: RgColors.muted,
    ),
  );
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  const _DateField({required this.label, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _parse(value) ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(DateFormat('yyyy-MM-dd').format(picked));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: RgColors.bg,
          borderRadius: RgRadius.smAll,
          border: Border.all(color: RgColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: RgColors.muted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value != null ? _display(value!) : 'Select',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RgColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: RgColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parse(String? d) => d != null ? DateTime.tryParse(d) : null;
  String _display(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd/MM/yy').format(dt) : d;
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _Tag({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: RgColors.primary.withOpacity(0.08),
        borderRadius: RgRadius.fullAll,
        border: Border.all(color: RgColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: RgColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: RgColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool hasBadge;
  final bool loading;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.color = RgColors.primary,
    this.hasBadge = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: RgRadius.smAll,
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: loading
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  )
                : Icon(
                    icon,
                    color: onTap != null ? color : RgColors.border,
                    size: 18,
                  ),
          ),
          if (hasBadge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: RgColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RgColors.dangerBg,
        borderRadius: RgRadius.smAll,
        border: Border.all(color: RgColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: RgColors.danger,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: RgColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              size: 15,
              color: RgColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ── internal model ────────────────────────────────────────────
class _QR {
  final String label, start, end;
  const _QR(this.label, this.start, this.end);
}

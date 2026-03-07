import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/sales_report_provider.dart';

class FilterSectionWidget extends ConsumerStatefulWidget {
  const FilterSectionWidget({super.key});

  @override
  ConsumerState<FilterSectionWidget> createState() =>
      _FilterSectionWidgetState();
}

class _FilterSectionWidgetState extends ConsumerState<FilterSectionWidget> {
  final _customerNameCtrl = TextEditingController();
  String? _status;
  String? _groupBy;

  static const _statusOptions = [
    MapEntry('', 'All Status'),
    MapEntry('PENDING', 'Pending'),
    MapEntry('CONFIRMED', 'Confirmed'),
    MapEntry('SHIPPED', 'Shipped'),
    MapEntry('DELIVERED', 'Delivered'),
    MapEntry('CANCELLED', 'Cancelled'),
    MapEntry('PROCESSING', 'Processing'),
  ];

  static const _groupByOptions = [
    MapEntry('', 'No Group'),
    MapEntry('DAY', 'Day'),
    MapEntry('WEEK', 'Week'),
    MapEntry('MONTH', 'Month'),
    MapEntry('YEAR', 'Year'),
  ];

  static final _quickRanges = _buildQuickRanges();

  static List<_QuickRange> _buildQuickRanges() {
    final fmt = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    return [
      _QuickRange('Today', fmt.format(now), fmt.format(now)),
      _QuickRange(
          'This Week',
          fmt.format(now.subtract(Duration(days: now.weekday - 1))),
          fmt.format(now)),
      _QuickRange('This Month',
          fmt.format(DateTime(now.year, now.month, 1)), fmt.format(now)),
      _QuickRange(
          'Last Month',
          fmt.format(DateTime(now.year, now.month - 1, 1)),
          fmt.format(DateTime(now.year, now.month, 0))),
      _QuickRange('Last 7d',
          fmt.format(now.subtract(const Duration(days: 6))), fmt.format(now)),
      _QuickRange('Last 30d',
          fmt.format(now.subtract(const Duration(days: 29))), fmt.format(now)),
      _QuickRange(
          'This Year', fmt.format(DateTime(now.year, 1, 1)), fmt.format(now)),
    ];
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(
        customerNameCtrl: _customerNameCtrl,
        status: _status,
        groupBy: _groupBy,
        statusOptions: _statusOptions,
        groupByOptions: _groupByOptions,
        onStatusChanged: (v) => setState(() => _status = v),
        onGroupByChanged: (v) => setState(() => _groupBy = v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesReportProvider);
    final notifier = ref.read(salesReportProvider.notifier);
    final filter = state.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Date Range Display + Filter Button ────────────────
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(children: [
                  const Icon(Icons.date_range_rounded,
                      size: 16, color: Color(0xFF4C9EFF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateLabel(filter.startDate, filter.endDate),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            _IconBtn(
              icon: Icons.tune_rounded,
              onTap: _openFilterSheet,
              badge: _hasActiveFilters(filter),
            ),
            const SizedBox(width: 8),
            if (state.isExporting)
              const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else
              _IconBtn(
                icon: Icons.file_download_rounded,
                color: const Color(0xFF00C896),
                onTap: () => notifier.exportReport((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Export ready'),
                        behavior: SnackBarBehavior.floating),
                  );
                }),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // ─── Quick Range Chips ─────────────────────────────────
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickRanges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final r = _quickRanges[i];
              final isSelected = filter.startDate == r.startDate &&
                  filter.endDate == r.endDate;
              return GestureDetector(
                onTap: () => notifier.applyQuickRange(r.startDate, r.endDate),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4C9EFF)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.label,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : Colors.grey.shade700),
                  ),
                ),
              );
            },
          ),
        ),

        // ─── Active Filter Tags ────────────────────────────────
        if (_status != null && _status!.isNotEmpty ||
            _groupBy != null && _groupBy!.isNotEmpty ||
            (filter.customerName ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              if (_status != null && _status!.isNotEmpty)
                _ActiveTag(
                    label: _status!,
                    onRemove: () {
                      setState(() => _status = null);
                      notifier
                          .updateFilter(filter.copyWith(status: ''));
                    }),
              if (_groupBy != null && _groupBy!.isNotEmpty)
                _ActiveTag(
                    label: 'Group: $_groupBy',
                    onRemove: () {
                      setState(() => _groupBy = null);
                      notifier
                          .updateFilter(filter.copyWith(groupBy: ''));
                    }),
              if ((filter.customerName ?? '').isNotEmpty)
                _ActiveTag(
                    label: filter.customerName!,
                    onRemove: () {
                      _customerNameCtrl.clear();
                      notifier.updateFilter(filter.copyWith(customerName: ''));
                    }),
            ],
          ),
        ],

        // ─── Error Banner ──────────────────────────────────────
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          _ErrorBanner(
              message: state.errorMessage!, onDismiss: notifier.clearError),
        ],
      ],
    );
  }

  bool _hasActiveFilters(dynamic filter) =>
      (filter.status ?? '').isNotEmpty ||
      (filter.customerName ?? '').isNotEmpty;

  String _dateLabel(String? start, String? end) {
    if (start == null && end == null) return 'Select date range';
    final fmt = DateFormat('d MMM y');
    final s = start != null ? fmt.format(DateTime.parse(start)) : '—';
    final e = end != null ? fmt.format(DateTime.parse(end)) : '—';
    return '$s → $e';
  }
}

// ═════════════════════════════════════════════
// Filter Bottom Sheet
// ═════════════════════════════════════════════

class _FilterBottomSheet extends ConsumerStatefulWidget {
  final TextEditingController customerNameCtrl;
  final String? status;
  final String? groupBy;
  final List<MapEntry<String, String>> statusOptions;
  final List<MapEntry<String, String>> groupByOptions;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onGroupByChanged;

  const _FilterBottomSheet({
    required this.customerNameCtrl,
    required this.status,
    required this.groupBy,
    required this.statusOptions,
    required this.groupByOptions,
    required this.onStatusChanged,
    required this.onGroupByChanged,
  });

  @override
  ConsumerState<_FilterBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late String? _status;
  late String? _groupBy;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _groupBy = widget.groupBy;
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filters',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    widget.customerNameCtrl.clear();
                    setState(() {
                      _status = null;
                      _groupBy = null;
                    });
                    widget.onStatusChanged(null);
                    widget.onGroupByChanged(null);
                    notifier.resetFilters();
                  },
                  child: const Text('Reset all',
                      style: TextStyle(color: Color(0xFFFF5F5F))),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date pickers
                  Row(children: [
                    Expanded(
                        child: _SheetDateField(
                      label: 'Start Date',
                      value: filter.startDate,
                      onChanged: (d) => notifier
                          .updateFilter(filter.copyWith(startDate: d)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _SheetDateField(
                      label: 'End Date',
                      value: filter.endDate,
                      onChanged: (d) =>
                          notifier.updateFilter(filter.copyWith(endDate: d)),
                    )),
                  ]),
                  const SizedBox(height: 16),

                  // Customer Name
                  TextField(
                    controller: widget.customerNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      hintText: 'Search by name…',
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200)),
                      prefixIcon:
                          const Icon(Icons.search_rounded, size: 18),
                    ),
                    onChanged: (v) => notifier
                        .updateFilter(filter.copyWith(customerName: v)),
                  ),
                  const SizedBox(height: 16),

                  // Status chips
                  const Text('Status',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.statusOptions.map((e) {
                      final selected =
                          (_status ?? '') == e.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _status = e.key);
                          widget.onStatusChanged(e.key);
                          notifier.updateFilter(
                              filter.copyWith(status: e.key));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF4C9EFF)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(e.value,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey.shade700)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Group By
                  const Text('Group By',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.groupByOptions.map((e) {
                      final selected = (_groupBy ?? '') == e.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _groupBy = e.key);
                          widget.onGroupByChanged(e.key);
                          notifier.updateFilter(
                              filter.copyWith(groupBy: e.key));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFF9F43)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(e.value,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey.shade700)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Toggle options
                  Row(children: [
                    Expanded(
                      child: _ToggleRow(
                        label: 'Use Cache',
                        value: filter.useCache,
                        onChanged: (v) => notifier
                            .updateFilter(filter.copyWith(useCache: v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ToggleRow(
                        label: 'Materialized View',
                        value: filter.useMaterializedView,
                        onChanged: (v) => notifier.updateFilter(
                            filter.copyWith(useMaterializedView: v)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4C9EFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  notifier.applyFilters();
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _SheetDateField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  const _SheetDateField(
      {required this.label, required this.value, required this.onChanged});

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
        if (picked != null) {
          onChanged(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(
                value != null ? _display(value!) : 'Select',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          Icon(Icons.calendar_today_rounded,
              size: 15, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  DateTime? _parse(String? d) => d != null ? DateTime.tryParse(d) : null;
  String _display(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd/MM/yy').format(dt) : d;
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600))),
        SizedBox(
          height: 24,
          child: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4C9EFF),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ]),
    );
  }
}

class _ActiveTag extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveTag({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4C9EFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C9EFF))),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close_rounded,
              size: 13, color: Color(0xFF4C9EFF)),
        ),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  final Color color;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.badge = false,
    this.color = const Color(0xFF4C9EFF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFFFF5F5F), shape: BoxShape.circle),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5F5F).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF5F5F).withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: Color(0xFFFF5F5F), size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFFF5F5F)))),
        GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                size: 16, color: Color(0xFFFF5F5F))),
      ]),
    );
  }
}

class _QuickRange {
  final String label;
  final String startDate;
  final String endDate;
  const _QuickRange(this.label, this.startDate, this.endDate);
}
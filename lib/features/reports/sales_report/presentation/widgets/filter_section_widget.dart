import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sales_report_entities.dart';
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
    MapEntry('', 'No Grouping'),
    MapEntry('DAY', 'By Day'),
    MapEntry('WEEK', 'By Week'),
    MapEntry('MONTH', 'By Month'),
    MapEntry('YEAR', 'By Year'),
  ];

  static final _quickRanges = _buildQuickRanges();

  static List<_QuickRange> _buildQuickRanges() {
    final fmt = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    return [
      _QuickRange(
        'Today',
        fmt.format(now),
        fmt.format(now),
      ),
      _QuickRange(
        'This Week',
        fmt.format(now.subtract(Duration(days: now.weekday - 1))),
        fmt.format(now),
      ),
      _QuickRange(
        'This Month',
        fmt.format(DateTime(now.year, now.month, 1)),
        fmt.format(now),
      ),
      _QuickRange(
        'Last Month',
        fmt.format(DateTime(now.year, now.month - 1, 1)),
        fmt.format(DateTime(now.year, now.month, 0)),
      ),
      _QuickRange(
        'Last 7 Days',
        fmt.format(now.subtract(const Duration(days: 6))),
        fmt.format(now),
      ),
      _QuickRange(
        'Last 30 Days',
        fmt.format(now.subtract(const Duration(days: 29))),
        fmt.format(now),
      ),
      _QuickRange(
        'This Year',
        fmt.format(DateTime(now.year, 1, 1)),
        fmt.format(now),
      ),
    ];
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesReportProvider);
    final notifier = ref.read(salesReportProvider.notifier);
    final filter = state.filter;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Date + Status + GroupBy ───────────────────────
            // Uses Wrap so fields reflow on narrow screens
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FilterBox(
                  child: _DateField(
                    label: 'Start Date',
                    value: filter.startDate,
                    onChanged: (d) =>
                        notifier.updateFilter(filter.copyWith(startDate: d)),
                  ),
                ),
                _FilterBox(
                  child: _DateField(
                    label: 'End Date',
                    value: filter.endDate,
                    onChanged: (d) =>
                        notifier.updateFilter(filter.copyWith(endDate: d)),
                  ),
                ),
                _FilterBox(
                  child: _DropdownField<String>(
                    label: 'Status',
                    value: _status ?? '',
                    items: _statusOptions,
                    onChanged: (v) {
                      setState(() => _status = v);
                      notifier.updateFilter(filter.copyWith(status: v));
                    },
                  ),
                ),
                _FilterBox(
                  child: _DropdownField<String>(
                    label: 'Group By',
                    value: _groupBy ?? '',
                    items: _groupByOptions,
                    onChanged: (v) {
                      setState(() => _groupBy = v);
                      notifier.updateFilter(filter.copyWith(groupBy: v));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Customer Name ─────────────────────────────────
            TextField(
              controller: _customerNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Search by name...',
                isDense: true,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search, size: 18),
              ),
              onChanged: (v) =>
                  notifier.updateFilter(filter.copyWith(customerName: v)),
            ),
            const SizedBox(height: 10),

            // ─── Toggle Chips ─────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _ToggleChip(
                  label: 'Use Cache',
                  value: filter.useCache,
                  onChanged: (v) =>
                      notifier.updateFilter(filter.copyWith(useCache: v)),
                ),
                _ToggleChip(
                  label: 'Materialized View',
                  value: filter.useMaterializedView,
                  onChanged: (v) => notifier
                      .updateFilter(filter.copyWith(useMaterializedView: v)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Quick Ranges ──────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _quickRanges.map((r) {
                return ActionChip(
                  label: Text(r.label, style: const TextStyle(fontSize: 12)),
                  onPressed: () =>
                      notifier.applyQuickRange(r.startDate, r.endDate),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // ─── Action Buttons ────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: notifier.applyFilters,
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: const Text('Apply Filters'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    _customerNameCtrl.clear();
                    setState(() {
                      _status = null;
                      _groupBy = null;
                    });
                    notifier.resetFilters();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                ),
                if (state.isExporting)
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  FilledButton.icon(
                    style:
                        FilledButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => notifier.exportReport((bytes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Export ready for download')),
                      );
                    }),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Export Excel'),
                  ),
              ],
            ),

            // ─── Error ────────────────────────────────────────
            if (state.errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                    IconButton(
                      onPressed: notifier.clearError,
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  const _DateField(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _parseDate(value) ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onChanged(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 16),
        ),
        child: Text(
          value != null ? _display(value!) : 'Select',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  DateTime? _parseDate(String? d) {
    if (d == null) return null;
    return DateTime.tryParse(d);
  }

  String _display(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd/MM/yyyy').format(dt) : d;
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<MapEntry<T, String>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleChip(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: value,
      onSelected: onChanged,
    );
  }
}

class _QuickRange {
  final String label;
  final String startDate;
  final String endDate;
  const _QuickRange(this.label, this.startDate, this.endDate);
}

/// Constrains each filter field to a comfortable fixed width so they
/// wrap cleanly inside the Wrap widget on narrow screens.
class _FilterBox extends StatelessWidget {
  final Widget child;
  const _FilterBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 180, child: child);
  }
}
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Summary Strip ─────────────────────────────────────
        Row(children: [
          _MiniStat(
              label: 'Products',
              value: '${pp.summary.totalUniqueProducts}',
              color: const Color(0xFF4C9EFF)),
          const SizedBox(width: 8),
          _MiniStat(
              label: 'Items Sold',
              value: '${pp.summary.totalQuantitySold}',
              color: const Color(0xFFFF9F43)),
          const SizedBox(width: 8),
          _MiniStat(
              label: 'Revenue',
              value: _compact(pp.summary.totalRevenue),
              color: const Color(0xFF00C896)),
        ]),
        const SizedBox(height: 12),

        // ─── Product Cards ─────────────────────────────────────
        if (pp.topProducts.isEmpty)
          _EmptyState(icon: Icons.inventory_2_outlined, label: 'No products')
        else
          ...pp.topProducts.asMap().entries.map((e) {
            final p = e.value;
            final rank = e.key + 1;
            return _ProductCard(product: p, rank: rank);
          }),
      ],
    );
  }

  static String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return NumberFormat('#,##0').format(v);
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final int rank;
  const _ProductCard({required this.product, required this.rank});

  @override
  Widget build(BuildContext context) {
    final pct = product.revenuePercentage as double;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _RankBadge(rank: rank),
            const SizedBox(width: 10),
            Expanded(
              child: Text(product.itemName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Text(
              NumberFormat('#,##0.00').format(product.totalRevenue),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00C896)),
            ),
          ]),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(
                  _rankColor(rank).withOpacity(0.7)),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          // Stats row
          Row(children: [
            _Chip(
                icon: Icons.shopping_bag_rounded,
                label: '${product.totalQuantitySold} sold',
                color: const Color(0xFF4C9EFF)),
            const SizedBox(width: 6),
            _Chip(
                icon: Icons.receipt_rounded,
                label: '${product.orderCount} orders',
                color: const Color(0xFFFF9F43)),
            const Spacer(),
            Text('${pct.toStringAsFixed(1)}% of total',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  Color _rankColor(int r) {
    if (r == 1) return const Color(0xFFFFD700);
    if (r == 2) return const Color(0xFFC0C0C0);
    if (r == 3) return const Color(0xFFCD7F32);
    return const Color(0xFF4C9EFF);
  }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Summary Strip ─────────────────────────────────────
        _MiniStat(
            label: 'Total Customers',
            value: '${ca.summary.totalCustomers}',
            color: const Color(0xFFA78BFA)),
        const SizedBox(height: 12),

        // ─── Customer Cards ────────────────────────────────────
        if (ca.topCustomers.isEmpty)
          _EmptyState(icon: Icons.people_outline_rounded, label: 'No customers')
        else
          ...ca.topCustomers.asMap().entries.map((e) {
            final c = e.value;
            final rank = e.key + 1;
            return _CustomerCard(customer: c, rank: rank);
          }),
      ],
    );
  }

  static String _currency(double v) =>
      NumberFormat('#,##0.00', 'en_US').format(v);
}

class _CustomerCard extends StatelessWidget {
  final dynamic customer;
  final int rank;
  const _CustomerCard({required this.customer, required this.rank});

  @override
  Widget build(BuildContext context) {
    final days = customer.daysSinceLastOrder as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Rank + Name + Total Spent
          Row(children: [
            _RankBadge(rank: rank),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.customerName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if ((customer.companyName ?? '').isNotEmpty)
                      Text(customer.companyName!,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                NumberFormat('#,##0.00').format(customer.totalSpent),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00C896)),
              ),
              Text('total spent',
                  style: TextStyle(
                      fontSize: 9.5, color: Colors.grey.shade400)),
            ]),
          ]),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Row 2: Stats chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Chip(
                  icon: Icons.receipt_outlined,
                  label: '${customer.totalOrders} orders',
                  color: const Color(0xFF4C9EFF)),
              _Chip(
                  icon: Icons.phone_rounded,
                  label: customer.phone,
                  color: Colors.grey.shade600),
              _Chip(
                  icon: Icons.event_rounded,
                  label: _fmtDate(customer.lastOrderDate),
                  color: const Color(0xFFFF9F43)),
              _DaysChip(days: days),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yy').format(dt) : d;
  }
}

// ─────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  Color get _color {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF9CA3AF);
    if (rank == 3) return const Color(0xFFCD7F32);
    return const Color(0xFF4C9EFF);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
          color: _color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text('#$rank',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _color)),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _DaysChip extends StatelessWidget {
  final int days;
  const _DaysChip({required this.days});

  Color get _color {
    if (days <= 30) return const Color(0xFF00C896);
    if (days <= 90) return const Color(0xFFFF9F43);
    return const Color(0xFFFF5F5F);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.access_time_rounded, size: 11, color: _color),
        const SizedBox(width: 4),
        Text('$days days ago',
            style: TextStyle(
                fontSize: 11,
                color: _color,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ]),
      ),
    );
  }
}
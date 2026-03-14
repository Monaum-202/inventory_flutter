// ============================================================
//  sales_report_page.dart  —  filter · table · export only
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_app/core/widgets/rg_tokens.dart';

import '../providers/sales_report_provider.dart';
import '../widgets/filter_section_widget.dart';
import '../widgets/sales_table_widget.dart';

class SalesReportPage extends ConsumerWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesReportProvider);

    return Scaffold(
      backgroundColor: RgColors.bg,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilterSectionWidget(),
                SizedBox(height: 12),
                SalesTableWidget(),
              ],
            ),
          ),
          if (state.isLoading) const _LoadingOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: const BoxDecoration(
          color: RgColors.surface,
          border: Border(
            top: BorderSide(color: RgColors.primary, width: 3),
            bottom: BorderSide(color: RgColors.border),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [RgColors.primary, Color(0xFF6C63FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: RgRadius.smAll,
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Sales Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: RgColors.text,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          decoration: BoxDecoration(
            color: RgColors.surface,
            borderRadius: RgRadius.lgAll,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(RgColors.primary),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Loading…',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: RgColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

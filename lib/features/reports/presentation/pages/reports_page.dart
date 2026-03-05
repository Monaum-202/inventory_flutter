import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_app/features/reports/inventory_report/presentation/pages/inventory_report_page.dart';
import 'package:inventory_app/features/reports/purchase_report/presentation/pages/purchase_report_page.dart';
import 'package:inventory_app/features/reports/sales_report/presentation/pages/sales_report_page.dart';
import 'package:inventory_app/features/reports/income_report/presentation/pages/income_report_page.dart';
import 'package:inventory_app/main.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Inventory Report',
    'Purchase Report',
    'Sales Report',
    'Income Report',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      ref.read(reportsSubIndexProvider.notifier).state = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subIndex = ref.watch(reportsSubIndexProvider);
    _tabController.index = subIndex;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const InventoryReportPage(),
              const PurchaseReportPage(),
              const SalesReportPage(),
              const IncomeReportPage(),
            ],
          ),
        ),
      ],
    );
  }
}

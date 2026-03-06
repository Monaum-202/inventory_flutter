import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_app/features/reports/inventory_report/presentation/pages/inventory_report_page.dart';
import 'package:inventory_app/features/reports/purchase_report/presentation/pages/purchase_report_page.dart';
import 'package:inventory_app/features/reports/sales_report/presentation/pages/sales_report_page.dart';
import 'package:inventory_app/features/reports/income_report/presentation/pages/income_report_page.dart';
import 'package:inventory_app/main.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subIndex = ref.watch(reportsSubIndexProvider);

    final List<Widget> reportPages = [
      const InventoryReportPage(),
      const PurchaseReportPage(),
      const SalesReportPage(),
      const IncomeReportPage(),
    ];

    return reportPages[subIndex];
  }
}

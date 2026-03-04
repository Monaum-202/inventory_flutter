import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  DashboardSummaryModel({
    required int totalItems,
    required int lowStockItems,
    required double totalValue,
  }) : super(
          totalItems: totalItems,
          lowStockItems: lowStockItems,
          totalValue: totalValue,
        );

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalItems: json['totalItems'] as int,
      lowStockItems: json['lowStockItems'] as int,
      totalValue: (json['totalValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'lowStockItems': lowStockItems,
      'totalValue': totalValue,
    };
  }
}

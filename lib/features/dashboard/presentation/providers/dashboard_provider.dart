import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider = Provider<DashboardState>((ref) {
  // TODO: connect to domain/use cases
  return DashboardState.initial();
});

class DashboardState {
  final int totalItems;
  final int lowStockCount;
  final double totalValue;

  DashboardState({
    required this.totalItems,
    required this.lowStockCount,
    required this.totalValue,
  });

  factory DashboardState.initial() {
    return DashboardState(totalItems: 0, lowStockCount: 0, totalValue: 0.0);
  }
}

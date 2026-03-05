import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_provider.dart';
import '../models/metric_model.dart';
import '../models/stock_model.dart';
import '../models/revenue_model.dart';
import '../models/expense_model.dart';
import '../models/trend_model.dart';
import '../repositories/dashboard_repository.dart';

// Repository provider
final dashboardRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DashboardRepositoryImpl(apiService: apiService, ref: ref);
});

// Metrics provider
final dashboardMetricsProvider = FutureProvider.family<MetricsResponse, String>((ref, period) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getMetrics(period);
});

// Stock provider
final dashboardStockProvider = FutureProvider<StockResponse>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getStockData();
});

// Revenue details provider
final dashboardRevenueProvider = FutureProvider.family<RevenueResponse, String>((ref, period) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRevenueDetails(period);
});

// Expense details provider
final dashboardExpenseProvider = FutureProvider.family<ExpenseResponse, String>((ref, period) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getExpenseDetails(period);
});

// Trends provider
final dashboardTrendProvider = FutureProvider.family<TrendResponse, String>((ref, period) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getTrends(period);
});

// Selected period state provider
final selectedPeriodProvider = StateProvider<String>((ref) => 'MONTH');


import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/metric_model.dart';
import '../models/stock_model.dart';
import '../models/revenue_model.dart';
import '../models/expense_model.dart';
import '../models/trend_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/data/providers/auth_provider.dart';

abstract class DashboardRepository {
  Future<MetricsResponse> getMetrics(String period);
  Future<StockResponse> getStockData();
  Future<RevenueResponse> getRevenueDetails(String period);
  Future<ExpenseResponse> getExpenseDetails(String period);
  Future<TrendResponse> getTrends(String period);
}

class UnauthorizedException implements Exception {}

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiService apiService;
  final Ref ref;

  DashboardRepositoryImpl({required this.apiService, required this.ref});

  void _checkAuth(http.Response response) {
    if (response.statusCode == 401) {
      // token invalid/expired -> force logout
      ref.read(authStateProvider.notifier).logout();
      throw UnauthorizedException();
    }
  }

  @override
  Future<MetricsResponse> getMetrics(String period) async {
    final response = await apiService.get('/api/dashboard/metrics?period=$period');
    _checkAuth(response);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return MetricsResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch metrics');
    }
  }

  @override
  Future<StockResponse> getStockData() async {
    final response = await apiService.get('/api/dashboard/stock');
    _checkAuth(response);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return StockResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch stock data');
    }
  }

  @override
  Future<RevenueResponse> getRevenueDetails(String period) async {
    final response = await apiService.get('/api/dashboard/revenue-details?period=$period');
    _checkAuth(response);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return RevenueResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch revenue details');
    }
  }

  @override
  Future<ExpenseResponse> getExpenseDetails(String period) async {
    final response = await apiService.get('/api/dashboard/expense-details?period=$period');
    _checkAuth(response);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ExpenseResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch expense details');
    }
  }

  @override
  Future<TrendResponse> getTrends(String period) async {
    final response = await apiService.get('/api/dashboard/trends?period=$period');
    _checkAuth(response);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return TrendResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch trends');
    }
  }
}


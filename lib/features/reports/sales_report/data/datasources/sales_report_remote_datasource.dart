import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/services/api_service.dart';
import '../../domain/entities/sales_report_entities.dart';
import '../models/sales_report_models.dart';

class SalesReportRemoteDataSource {
  final ApiService apiService;

  const SalesReportRemoteDataSource(this.apiService);

  // ─── Sales Report ────────────────────────────────────────────
  Future<SalesReportModel> getSalesReport(
    SalesReportFilter filter, {
    int page = 0,
    int size = 20,
  }) async {
    final params = filter.toQueryParams(page: page, size: size);
    final uri = Uri.parse(
      '/api/reports/sales',
    ).replace(queryParameters: params);
    final response = await apiService.get(uri.toString());
    _checkStatus(response);
    return SalesReportModel.fromJson(jsonDecode(response.body));
  }

  // ─── Product Performance ──────────────────────────────────────
  Future<ProductPerformanceModel> getProductPerformance(
    SalesReportFilter filter, {
    int limit = 10,
  }) async {
    final params = {...filter.toQueryParams(), 'limit': '$limit'};
    final uri = Uri.parse(
      '/api/sales-reports/products',
    ).replace(queryParameters: params);
    final response = await apiService.get(uri.toString());
    _checkStatus(response);
    return ProductPerformanceModel.fromJson(jsonDecode(response.body));
  }

  // ─── Customer Analytics ───────────────────────────────────────
  Future<CustomerAnalyticsModel> getCustomerAnalytics(
    SalesReportFilter filter, {
    int limit = 10,
  }) async {
    final params = {...filter.toQueryParams(), 'limit': '$limit'};
    final uri = Uri.parse(
      '/api/sales-reports/customers',
    ).replace(queryParameters: params);
    final response = await apiService.get(uri.toString());
    _checkStatus(response);
    return CustomerAnalyticsModel.fromJson(jsonDecode(response.body));
  }

  // ─── Export ───────────────────────────────────────────────────
  // sales_report_remote_datasource.dart

  Future<List<int>> exportReport(SalesReportFilter filter) async {
    final params = {
      'dateFrom': filter.startDate ?? '',
      'dateTo': filter.endDate ?? '',
      'status': filter.status ?? '',
      'customerName': filter.customerName ?? '',
    };

    final uri = Uri.parse(
      '/api/reports/sales/pdf',
    ).replace(queryParameters: params);

    final response = await apiService.get(uri.toString());
    _checkStatus(response);
    return response.bodyBytes.toList();
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'API error ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }
}

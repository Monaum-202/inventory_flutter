import '../entities/sales_report_entities.dart';
import '../repositories/sales_report_repository.dart';

// ─────────────────────────────────────────────
class GetSalesReportUseCase {
  final SalesReportRepository repository;
  const GetSalesReportUseCase(this.repository);

  Future<SalesReport> call(
    SalesReportFilter filter, {
    int page = 0,
    int size = 20,
  }) =>
      repository.getSalesReport(filter, page: page, size: size);
}

// ─────────────────────────────────────────────
class GetProductPerformanceUseCase {
  final SalesReportRepository repository;
  const GetProductPerformanceUseCase(this.repository);

  Future<ProductPerformance> call(
    SalesReportFilter filter, {
    int limit = 10,
  }) =>
      repository.getProductPerformance(filter, limit: limit);
}

// ─────────────────────────────────────────────
class GetCustomerAnalyticsUseCase {
  final SalesReportRepository repository;
  const GetCustomerAnalyticsUseCase(this.repository);

  Future<CustomerAnalytics> call(
    SalesReportFilter filter, {
    int limit = 10,
  }) =>
      repository.getCustomerAnalytics(filter, limit: limit);
}

// ─────────────────────────────────────────────
class ExportReportUseCase {
  final SalesReportRepository repository;
  const ExportReportUseCase(this.repository);

  Future<List<int>> call(SalesReportFilter filter) =>
      repository.exportReport(filter);
}
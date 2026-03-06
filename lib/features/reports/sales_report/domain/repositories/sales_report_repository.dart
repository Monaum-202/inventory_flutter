import '../entities/sales_report_entities.dart';

abstract class SalesReportRepository {
  Future<SalesReport> getSalesReport(
    SalesReportFilter filter, {
    int page = 0,
    int size = 20,
  });

  Future<ProductPerformance> getProductPerformance(
    SalesReportFilter filter, {
    int limit = 10,
  });

  Future<CustomerAnalytics> getCustomerAnalytics(
    SalesReportFilter filter, {
    int limit = 10,
  });

  Future<List<int>> exportReport(SalesReportFilter filter);
}
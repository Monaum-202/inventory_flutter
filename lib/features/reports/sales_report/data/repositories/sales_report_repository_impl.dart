import '../../domain/entities/sales_report_entities.dart';
import '../../domain/repositories/sales_report_repository.dart';
import '../datasources/sales_report_remote_datasource.dart';

class SalesReportRepositoryImpl implements SalesReportRepository {
  final SalesReportRemoteDataSource remoteDataSource;

  const SalesReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SalesReport> getSalesReport(
    SalesReportFilter filter, {
    int page = 0,
    int size = 20,
  }) =>
      remoteDataSource.getSalesReport(filter, page: page, size: size);

  @override
  Future<ProductPerformance> getProductPerformance(
    SalesReportFilter filter, {
    int limit = 10,
  }) =>
      remoteDataSource.getProductPerformance(filter, limit: limit);

  @override
  Future<CustomerAnalytics> getCustomerAnalytics(
    SalesReportFilter filter, {
    int limit = 10,
  }) =>
      remoteDataSource.getCustomerAnalytics(filter, limit: limit);

  @override
  Future<List<int>> exportReport(SalesReportFilter filter) =>
      remoteDataSource.exportReport(filter);
}
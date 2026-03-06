import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/api_provider.dart';
import '../datasources/sales_report_remote_datasource.dart';
import '../repositories/sales_report_repository_impl.dart';
import '../../domain/entities/sales_report_entities.dart';

// Repository provider
final salesReportRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final remoteDataSource = SalesReportRemoteDataSource(apiService);
  return SalesReportRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Sales report provider
final salesReportProvider =
    FutureProvider.family<SalesReport, SalesReportFilter>((ref, filter) async {
      final repository = ref.watch(salesReportRepositoryProvider);
      return repository.getSalesReport(filter);
    });

// Product performance provider
final productPerformanceProvider =
    FutureProvider.family<ProductPerformance, SalesReportFilter>((
      ref,
      filter,
    ) async {
      final repository = ref.watch(salesReportRepositoryProvider);
      return repository.getProductPerformance(filter);
    });

// Customer analytics provider
final customerAnalyticsProvider =
    FutureProvider.family<CustomerAnalytics, SalesReportFilter>((
      ref,
      filter,
    ) async {
      final repository = ref.watch(salesReportRepositoryProvider);
      return repository.getCustomerAnalytics(filter);
    });

// Current filter state provider
final salesReportFilterProvider = StateProvider<SalesReportFilter>(
  (ref) => const SalesReportFilter(),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/providers/api_provider.dart';
import '../../data/datasources/sales_report_remote_datasource.dart';
import '../../data/repositories/sales_report_repository_impl.dart';
import '../../domain/entities/sales_report_entities.dart';
import '../../domain/repositories/sales_report_repository.dart';
import '../../domain/usecases/sales_report_usecases.dart';

// ─────────────────────────────────────────────────────────────────
// Infrastructure providers
// ─────────────────────────────────────────────────────────────────

final salesReportDataSourceProvider = Provider<SalesReportRemoteDataSource>(
  (ref) => SalesReportRemoteDataSource(ref.read(apiServiceProvider)),
);

final salesReportRepositoryProvider = Provider<SalesReportRepository>(
  (ref) => SalesReportRepositoryImpl(
    remoteDataSource: ref.read(salesReportDataSourceProvider),
  ),
);

// ─────────────────────────────────────────────────────────────────
// Use case providers
// ─────────────────────────────────────────────────────────────────

final getSalesReportUseCaseProvider = Provider<GetSalesReportUseCase>(
  (ref) => GetSalesReportUseCase(ref.read(salesReportRepositoryProvider)),
);

final getProductPerformanceUseCaseProvider =
    Provider<GetProductPerformanceUseCase>(
      (ref) =>
          GetProductPerformanceUseCase(ref.read(salesReportRepositoryProvider)),
    );

final getCustomerAnalyticsUseCaseProvider =
    Provider<GetCustomerAnalyticsUseCase>(
      (ref) =>
          GetCustomerAnalyticsUseCase(ref.read(salesReportRepositoryProvider)),
    );

final exportReportUseCaseProvider = Provider<ExportReportUseCase>(
  (ref) => ExportReportUseCase(ref.read(salesReportRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────

enum SalesReportView { dashboard, table, products, customers }

class SalesReportState {
  final SalesReportFilter filter;
  final SalesReportView activeView;
  final int currentPage;
  final int pageSize;

  // Data
  final SalesReport? reportData;
  final ProductPerformance? productPerformance;
  final CustomerAnalytics? customerAnalytics;

  // Loading
  final bool isLoading;
  final bool isLoadingProducts;
  final bool isLoadingCustomers;
  final bool isExporting;

  // Error
  final String? errorMessage;

  const SalesReportState({
    required this.filter,
    this.activeView = SalesReportView.dashboard,
    this.currentPage = 0,
    this.pageSize = 20,
    this.reportData,
    this.productPerformance,
    this.customerAnalytics,
    this.isLoading = false,
    this.isLoadingProducts = false,
    this.isLoadingCustomers = false,
    this.isExporting = false,
    this.errorMessage,
  });

  SalesReportState copyWith({
    SalesReportFilter? filter,
    SalesReportView? activeView,
    int? currentPage,
    int? pageSize,
    SalesReport? reportData,
    ProductPerformance? productPerformance,
    CustomerAnalytics? customerAnalytics,
    bool? isLoading,
    bool? isLoadingProducts,
    bool? isLoadingCustomers,
    bool? isExporting,
    String? errorMessage,
    bool clearError = false,
    bool clearReport = false,
    bool clearProducts = false,
    bool clearCustomers = false,
  }) => SalesReportState(
    filter: filter ?? this.filter,
    activeView: activeView ?? this.activeView,
    currentPage: currentPage ?? this.currentPage,
    pageSize: pageSize ?? this.pageSize,
    reportData: clearReport ? null : (reportData ?? this.reportData),
    productPerformance: clearProducts
        ? null
        : (productPerformance ?? this.productPerformance),
    customerAnalytics: clearCustomers
        ? null
        : (customerAnalytics ?? this.customerAnalytics),
    isLoading: isLoading ?? this.isLoading,
    isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
    isLoadingCustomers: isLoadingCustomers ?? this.isLoadingCustomers,
    isExporting: isExporting ?? this.isExporting,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

// ─────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────

class SalesReportNotifier extends StateNotifier<SalesReportState> {
  final GetSalesReportUseCase _getSalesReport;
  final GetProductPerformanceUseCase _getProductPerformance;
  final GetCustomerAnalyticsUseCase _getCustomerAnalytics;
  final ExportReportUseCase _exportReport;

  SalesReportNotifier({
    required GetSalesReportUseCase getSalesReport,
    required GetProductPerformanceUseCase getProductPerformance,
    required GetCustomerAnalyticsUseCase getCustomerAnalytics,
    required ExportReportUseCase exportReport,
  }) : _getSalesReport = getSalesReport,
       _getProductPerformance = getProductPerformance,
       _getCustomerAnalytics = getCustomerAnalytics,
       _exportReport = exportReport,
       super(SalesReportState(filter: _defaultFilter())) {
    loadReport();
  }

  static SalesReportFilter _defaultFilter() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final fmt = DateFormat('yyyy-MM-dd');
    return SalesReportFilter(
      startDate: fmt.format(firstDay),
      endDate: fmt.format(now),
      useMaterializedView: true,
      useCache: true,
    );
  }

  // ─── Data loading ─────────────────────────────────────────────

  Future<void> loadReport() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final report = await _getSalesReport(
        state.filter,
        page: state.currentPage,
        size: state.pageSize,
      );
      state = state.copyWith(reportData: report, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load sales report',
      );
    }
  }

  Future<void> loadProductPerformance() async {
    state = state.copyWith(isLoadingProducts: true, clearError: true);
    try {
      final products = await _getProductPerformance(state.filter);
      state = state.copyWith(
        productPerformance: products,
        isLoadingProducts: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProducts: false,
        errorMessage: 'Failed to load product performance',
      );
    }
  }

  Future<void> loadCustomerAnalytics() async {
    state = state.copyWith(isLoadingCustomers: true, clearError: true);
    try {
      final customers = await _getCustomerAnalytics(state.filter);
      state = state.copyWith(
        customerAnalytics: customers,
        isLoadingCustomers: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCustomers: false,
        errorMessage: 'Failed to load customer analytics',
      );
    }
  }

  Future<void> exportReport(Function(List<int>) onSuccess) async {
    state = state.copyWith(isExporting: true, clearError: true);
    try {
      final bytes = await _exportReport(state.filter);
      onSuccess(bytes);
      state = state.copyWith(isExporting: false);
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Failed to export report',
      );
    }
  }

  // ─── Filter actions ───────────────────────────────────────────

  void updateFilter(SalesReportFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void applyFilters() {
    state = state.copyWith(currentPage: 0);
    final v = state.activeView;
    if (v == SalesReportView.dashboard || v == SalesReportView.table) {
      loadReport();
    } else if (v == SalesReportView.products) {
      loadProductPerformance();
    } else if (v == SalesReportView.customers) {
      loadCustomerAnalytics();
    }
  }

  void resetFilters() {
    state = state.copyWith(filter: _defaultFilter(), currentPage: 0);
    applyFilters();
  }

  void applyQuickRange(String startDate, String endDate) {
    state = state.copyWith(
      filter: state.filter.copyWith(startDate: startDate, endDate: endDate),
    );
    applyFilters();
  }

  // ─── View switching ───────────────────────────────────────────

  void switchView(SalesReportView view) {
    state = state.copyWith(activeView: view);
    if (view == SalesReportView.dashboard || view == SalesReportView.table) {
      if (state.reportData == null) loadReport();
    } else if (view == SalesReportView.products) {
      if (state.productPerformance == null) loadProductPerformance();
    } else if (view == SalesReportView.customers) {
      if (state.customerAnalytics == null) loadCustomerAnalytics();
    }
  }

  // ─── Pagination ───────────────────────────────────────────────

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
    loadReport();
  }

  void nextPage() {
    if (state.reportData?.pagination.hasNext == true) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadReport();
    }
  }

  void previousPage() {
    if (state.reportData?.pagination.hasPrevious == true) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      loadReport();
    }
  }

  void changePageSize(int size) {
    state = state.copyWith(pageSize: size, currentPage: 0);
    loadReport();
  }

  // ─── Error ────────────────────────────────────────────────────

  void clearError() => state = state.copyWith(clearError: true);
}

// ─────────────────────────────────────────────────────────────────
// Main provider
// ─────────────────────────────────────────────────────────────────

final salesReportProvider =
    StateNotifierProvider<SalesReportNotifier, SalesReportState>((ref) {
      return SalesReportNotifier(
        getSalesReport: ref.read(getSalesReportUseCaseProvider),
        getProductPerformance: ref.read(getProductPerformanceUseCaseProvider),
        getCustomerAnalytics: ref.read(getCustomerAnalyticsUseCaseProvider),
        exportReport: ref.read(exportReportUseCaseProvider),
      );
    });

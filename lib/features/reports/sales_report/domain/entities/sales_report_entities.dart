// ============================================================
// DOMAIN ENTITIES — pure Dart, no JSON / framework deps
// ============================================================

class SalesReportFilter {
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? customerName;
  final String? groupBy;
  final bool useMaterializedView;
  final bool useCache;

  const SalesReportFilter({
    this.startDate,
    this.endDate,
    this.status,
    this.customerName,
    this.groupBy,
    this.useMaterializedView = true,
    this.useCache = true,
  });

  SalesReportFilter copyWith({
    String? startDate,
    String? endDate,
    String? status,
    String? customerName,
    String? groupBy,
    bool? useMaterializedView,
    bool? useCache,
  }) =>
      SalesReportFilter(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        customerName: customerName ?? this.customerName,
        groupBy: groupBy ?? this.groupBy,
        useMaterializedView: useMaterializedView ?? this.useMaterializedView,
        useCache: useCache ?? this.useCache,
      );

  Map<String, String> toQueryParams({int page = 0, int size = 20}) => {
        'page': '$page',
        'size': '$size',
        'sortBy': 'sellDate',
        'sortDirection': 'DESC',
        if (startDate != null && startDate!.isNotEmpty) 'startDate': startDate!,
        if (endDate != null && endDate!.isNotEmpty) 'endDate': endDate!,
        if (status != null && status!.isNotEmpty) 'status': status!,
        if (customerName != null && customerName!.isNotEmpty)
          'customerName': customerName!,
        if (groupBy != null && groupBy!.isNotEmpty) 'groupBy': groupBy!,
        'useMaterializedView': '$useMaterializedView',
        'useCache': '$useCache',
      };
}

// ─────────────────────────────────────────────
class SalesSummary {
  final int totalOrders;
  final double totalRevenue;
  final double totalDiscount;
  final double totalVat;
  final double netRevenue;
  final double averageOrderValue;
  final int totalItemsSold;
  final int totalCustomers;
  final int pendingOrders;
  final int confirmedOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double pendingAmount;
  final double confirmedAmount;
  final double deliveredAmount;
  final double cancelledAmount;

  const SalesSummary({
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalDiscount,
    required this.totalVat,
    required this.netRevenue,
    required this.averageOrderValue,
    required this.totalItemsSold,
    required this.totalCustomers,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.pendingAmount,
    required this.confirmedAmount,
    required this.deliveredAmount,
    required this.cancelledAmount,
  });
}

// ─────────────────────────────────────────────
class SaleDetail {
  final int id;
  final String invoiceNo;
  final String sellDate;
  final String? deliveryDate;
  final String customerName;
  final String phone;
  final String? email;
  final String? companyName;
  final String status;
  final int totalItems;
  final double subtotal;
  final double discount;
  final double vat;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String? notes;

  const SaleDetail({
    required this.id,
    required this.invoiceNo,
    required this.sellDate,
    this.deliveryDate,
    required this.customerName,
    required this.phone,
    this.email,
    this.companyName,
    required this.status,
    required this.totalItems,
    required this.subtotal,
    required this.discount,
    required this.vat,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.notes,
  });
}

// ─────────────────────────────────────────────
class SalesPagination {
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const SalesPagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });
}

// ─────────────────────────────────────────────
class GroupedSalesData {
  final String groupLabel;
  final int orderCount;
  final double totalRevenue;
  final double averageOrderValue;
  final int? totalItems;

  const GroupedSalesData({
    required this.groupLabel,
    required this.orderCount,
    required this.totalRevenue,
    required this.averageOrderValue,
    this.totalItems,
  });
}

// ─────────────────────────────────────────────
class SalesReport {
  final SalesSummary summary;
  final List<SaleDetail> salesDetails;
  final SalesPagination pagination;
  final List<GroupedSalesData>? groupedData;

  const SalesReport({
    required this.summary,
    required this.salesDetails,
    required this.pagination,
    this.groupedData,
  });
}

// ─────────────────────────────────────────────
class TopProduct {
  final String itemName;
  final int totalQuantitySold;
  final double totalRevenue;
  final double averageUnitPrice;
  final int orderCount;
  final double revenuePercentage;

  const TopProduct({
    required this.itemName,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.averageUnitPrice,
    required this.orderCount,
    required this.revenuePercentage,
  });
}

class ProductPerformanceSummary {
  final int totalUniqueProducts;
  final int totalQuantitySold;
  final double totalRevenue;

  const ProductPerformanceSummary({
    required this.totalUniqueProducts,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });
}

class ProductPerformance {
  final ProductPerformanceSummary summary;
  final List<TopProduct> topProducts;

  const ProductPerformance({
    required this.summary,
    required this.topProducts,
  });
}

// ─────────────────────────────────────────────
class TopCustomer {
  final String customerName;
  final String? companyName;
  final String phone;
  final String? email;
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final String lastOrderDate;
  final int daysSinceLastOrder;

  const TopCustomer({
    required this.customerName,
    this.companyName,
    required this.phone,
    this.email,
    required this.totalOrders,
    required this.totalSpent,
    required this.averageOrderValue,
    required this.lastOrderDate,
    required this.daysSinceLastOrder,
  });
}

class CustomerAnalyticsSummary {
  final int totalCustomers;
  const CustomerAnalyticsSummary({required this.totalCustomers});
}

class CustomerAnalytics {
  final CustomerAnalyticsSummary summary;
  final List<TopCustomer> topCustomers;

  const CustomerAnalytics({
    required this.summary,
    required this.topCustomers,
  });
}
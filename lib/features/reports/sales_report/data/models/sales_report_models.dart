import '../../domain/entities/sales_report_entities.dart';

// ─────────────────────────────────────────────
class SalesSummaryModel extends SalesSummary {
  const SalesSummaryModel({
    required super.totalOrders,
    required super.totalRevenue,
    required super.totalDiscount,
    required super.totalVat,
    required super.netRevenue,
    required super.averageOrderValue,
    required super.totalItemsSold,
    required super.totalCustomers,
    required super.pendingOrders,
    required super.confirmedOrders,
    required super.shippedOrders,
    required super.deliveredOrders,
    required super.cancelledOrders,
    required super.pendingAmount,
    required super.confirmedAmount,
    required super.deliveredAmount,
    required super.cancelledAmount,
  });

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) =>
      SalesSummaryModel(
        totalOrders: json['totalOrders'] ?? 0,
        totalRevenue: _toDouble(json['totalRevenue']),
        totalDiscount: _toDouble(json['totalDiscount']),
        totalVat: _toDouble(json['totalVat']),
        netRevenue: _toDouble(json['netRevenue']),
        averageOrderValue: _toDouble(json['averageOrderValue']),
        totalItemsSold: json['totalItemsSold'] ?? 0,
        totalCustomers: json['totalCustomers'] ?? 0,
        pendingOrders: json['pendingOrders'] ?? 0,
        confirmedOrders: json['confirmedOrders'] ?? 0,
        shippedOrders: json['shippedOrders'] ?? 0,
        deliveredOrders: json['deliveredOrders'] ?? 0,
        cancelledOrders: json['cancelledOrders'] ?? 0,
        pendingAmount: _toDouble(json['pendingAmount']),
        confirmedAmount: _toDouble(json['confirmedAmount']),
        deliveredAmount: _toDouble(json['deliveredAmount']),
        cancelledAmount: _toDouble(json['cancelledAmount']),
      );
}

// ─────────────────────────────────────────────
class SaleDetailModel extends SaleDetail {
  const SaleDetailModel({
    required super.id,
    required super.invoiceNo,
    required super.sellDate,
    super.deliveryDate,
    required super.customerName,
    required super.phone,
    super.email,
    super.companyName,
    required super.status,
    required super.totalItems,
    required super.subtotal,
    required super.discount,
    required super.vat,
    required super.totalAmount,
    required super.paidAmount,
    required super.dueAmount,
    super.notes,
  });

  factory SaleDetailModel.fromJson(Map<String, dynamic> json) =>
      SaleDetailModel(
        id: json['id'] ?? 0,
        invoiceNo: json['invoiceNo'] ?? '',
        sellDate: json['sellDate'] ?? '',
        deliveryDate: json['deliveryDate'],
        customerName: json['customerName'] ?? '',
        phone: json['phone'] ?? '',
        email: _nullIfEmpty(json['email']),
        companyName: _nullIfEmpty(json['companyName']),
        status: json['status'] ?? '',
        totalItems: json['totalItems'] ?? 0,
        subtotal: _toDouble(json['subtotal']),
        discount: _toDouble(json['discount']),
        vat: _toDouble(json['vat']),
        totalAmount: _toDouble(json['totalAmount']),
        paidAmount: _toDouble(json['paidAmount']),
        dueAmount: _toDouble(json['dueAmount']),
        notes: _nullIfEmpty(json['notes']),
      );
}

// ─────────────────────────────────────────────
class SalesPaginationModel extends SalesPagination {
  const SalesPaginationModel({
    required super.currentPage,
    required super.pageSize,
    required super.totalElements,
    required super.totalPages,
    required super.hasNext,
    required super.hasPrevious,
  });

  factory SalesPaginationModel.fromJson(Map<String, dynamic> json) =>
      SalesPaginationModel(
        currentPage: json['currentPage'] ?? 0,
        pageSize: json['pageSize'] ?? 20,
        totalElements: json['totalElements'] ?? 0,
        totalPages: json['totalPages'] ?? 0,
        hasNext: json['hasNext'] ?? false,
        hasPrevious: json['hasPrevious'] ?? false,
      );
}

// ─────────────────────────────────────────────
class GroupedSalesDataModel extends GroupedSalesData {
  const GroupedSalesDataModel({
    required super.groupLabel,
    required super.orderCount,
    required super.totalRevenue,
    required super.averageOrderValue,
    super.totalItems,
  });

  factory GroupedSalesDataModel.fromJson(Map<String, dynamic> json) =>
      GroupedSalesDataModel(
        groupLabel: json['groupLabel'] ?? '',
        orderCount: json['orderCount'] ?? 0,
        totalRevenue: _toDouble(json['totalRevenue']),
        averageOrderValue: _toDouble(json['averageOrderValue']),
        totalItems: json['totalItems'],
      );
}

// ─────────────────────────────────────────────
class SalesReportModel extends SalesReport {
  const SalesReportModel({
    required super.summary,
    required super.salesDetails,
    required super.pagination,
    super.groupedData,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SalesReportModel(
      summary: SalesSummaryModel.fromJson(data['summary']),
      salesDetails: (data['salesDetails'] as List? ?? [])
          .map((e) => SaleDetailModel.fromJson(e))
          .toList(),
      pagination: SalesPaginationModel.fromJson(data['pagination']),
      groupedData: data['groupedData'] != null
          ? (data['groupedData'] as List)
              .map((e) => GroupedSalesDataModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

// ─────────────────────────────────────────────
class TopProductModel extends TopProduct {
  const TopProductModel({
    required super.itemName,
    required super.totalQuantitySold,
    required super.totalRevenue,
    required super.averageUnitPrice,
    required super.orderCount,
    required super.revenuePercentage,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) =>
      TopProductModel(
        itemName: json['itemName'] ?? '',
        totalQuantitySold: json['totalQuantitySold'] ?? 0,
        totalRevenue: _toDouble(json['totalRevenue']),
        averageUnitPrice: _toDouble(json['averageUnitPrice']),
        orderCount: json['orderCount'] ?? 0,
        revenuePercentage: _toDouble(json['revenuePercentage']),
      );
}

class ProductPerformanceModel extends ProductPerformance {
  const ProductPerformanceModel({
    required super.summary,
    required super.topProducts,
  });

  factory ProductPerformanceModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final summary = data['summary'] as Map<String, dynamic>;
    return ProductPerformanceModel(
      summary: ProductPerformanceSummary(
        totalUniqueProducts: summary['totalUniqueProducts'] ?? 0,
        totalQuantitySold: summary['totalQuantitySold'] ?? 0,
        totalRevenue: _toDouble(summary['totalRevenue']),
      ),
      topProducts: (data['topProducts'] as List? ?? [])
          .map((e) => TopProductModel.fromJson(e))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
class TopCustomerModel extends TopCustomer {
  const TopCustomerModel({
    required super.customerName,
    super.companyName,
    required super.phone,
    super.email,
    required super.totalOrders,
    required super.totalSpent,
    required super.averageOrderValue,
    required super.lastOrderDate,
    required super.daysSinceLastOrder,
  });

  factory TopCustomerModel.fromJson(Map<String, dynamic> json) =>
      TopCustomerModel(
        customerName: json['customerName'] ?? '',
        companyName: _nullIfEmpty(json['companyName']),
        phone: json['phone'] ?? '',
        email: _nullIfEmpty(json['email']),
        totalOrders: json['totalOrders'] ?? 0,
        totalSpent: _toDouble(json['totalSpent']),
        averageOrderValue: _toDouble(json['averageOrderValue']),
        lastOrderDate: json['lastOrderDate'] ?? '',
        daysSinceLastOrder: json['daysSinceLastOrder'] ?? 0,
      );
}

class CustomerAnalyticsModel extends CustomerAnalytics {
  const CustomerAnalyticsModel({
    required super.summary,
    required super.topCustomers,
  });

  factory CustomerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final summary = data['summary'] as Map<String, dynamic>;
    return CustomerAnalyticsModel(
      summary: CustomerAnalyticsSummary(
        totalCustomers: summary['totalCustomers'] ?? 0,
      ),
      topCustomers: (data['topCustomers'] as List? ?? [])
          .map((e) => TopCustomerModel.fromJson(e))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Helpers
double _toDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

String? _nullIfEmpty(dynamic val) {
  if (val == null) return null;
  final s = val.toString().trim();
  return s.isEmpty ? null : s;
}
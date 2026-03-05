class CategoryBreakdown {
  final String categoryName;
  final double amount;
  final int count;
  final double percentage;

  CategoryBreakdown({
    required this.categoryName,
    required this.amount,
    required this.count,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class PaymentMethodBreakdown {
  final String paymentMethodName;
  final double amount;
  final int count;

  PaymentMethodBreakdown({
    required this.paymentMethodName,
    required this.amount,
    required this.count,
  });

  factory PaymentMethodBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentMethodBreakdown(
      paymentMethodName: json['paymentMethodName'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
    );
  }
}

class RevenueResponse {
  final double totalRevenue;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<PaymentMethodBreakdown> paymentMethodBreakdown;
  final String period;

  RevenueResponse({
    required this.totalRevenue,
    required this.categoryBreakdown,
    required this.paymentMethodBreakdown,
    required this.period,
  });

  factory RevenueResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final categoryList = data['categoryBreakdown'] as List;
    final paymentList = data['paymentMethodBreakdown'] as List;

    return RevenueResponse(
      totalRevenue: (data['totalRevenue'] as num).toDouble(),
      categoryBreakdown:
          categoryList.map((item) => CategoryBreakdown.fromJson(item)).toList(),
      paymentMethodBreakdown: paymentList
          .map((item) => PaymentMethodBreakdown.fromJson(item))
          .toList(),
      period: data['period'] as String,
    );
  }
}

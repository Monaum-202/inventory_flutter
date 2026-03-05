class MetricValue {
  final double value;
  final String formattedValue;
  final int change;
  final String formattedChange;
  final bool positive;

  MetricValue({
    required this.value,
    required this.formattedValue,
    required this.change,
    required this.formattedChange,
    required this.positive,
  });

  factory MetricValue.fromJson(Map<String, dynamic> json) {
    return MetricValue(
      value: (json['value'] as num).toDouble(),
      formattedValue: json['formattedValue'] as String,
      change: (json['change'] as num).toInt(),
      formattedChange: json['formattedChange'] as String,
      positive: json['positive'] as bool,
    );
  }
}

class MetricsResponse {
  final MetricValue totalRevenue;
  final MetricValue totalExpenses;
  final MetricValue netProfit;
  final MetricValue profitMargin;
  final MetricValue totalOrders;
  final MetricValue totalCustomers;
  final MetricValue totalDue;
  final MetricValue totalOwed;
  final String period;
  final String startDate;
  final String endDate;

  MetricsResponse({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.totalOrders,
    required this.totalCustomers,
    required this.totalDue,
    required this.totalOwed,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  factory MetricsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MetricsResponse(
      totalRevenue: MetricValue.fromJson(data['totalRevenue']),
      totalExpenses: MetricValue.fromJson(data['totalExpenses']),
      netProfit: MetricValue.fromJson(data['netProfit']),
      profitMargin: MetricValue.fromJson(data['profitMargin']),
      totalOrders: MetricValue.fromJson(data['totalOrders']),
      totalCustomers: MetricValue.fromJson(data['totalCustomers']),
      totalDue: MetricValue.fromJson(data['totalDue']),
      totalOwed: MetricValue.fromJson(data['totalOwed']),
      period: data['period'] as String,
      startDate: data['startDate'] as String,
      endDate: data['endDate'] as String,
    );
  }
}

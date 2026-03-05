class TrendData {
  final String date;
  final double amount;
  final int count;

  TrendData({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
    );
  }
}

class TrendResponse {
  final List<TrendData> revenueTrend;
  final List<TrendData> expenseTrend;
  final String period;

  TrendResponse({
    required this.revenueTrend,
    required this.expenseTrend,
    required this.period,
  });

  factory TrendResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final revenueList = data['revenueTrend'] as List;
    final expenseList = data['expenseTrend'] as List;

    return TrendResponse(
      revenueTrend:
          revenueList.map((item) => TrendData.fromJson(item)).toList(),
      expenseTrend:
          expenseList.map((item) => TrendData.fromJson(item)).toList(),
      period: data['period'] as String,
    );
  }
}

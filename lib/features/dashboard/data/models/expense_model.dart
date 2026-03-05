class ExpenseResponse {
  final double totalExpenses;
  final List<dynamic> categoryBreakdown;
  final List<dynamic> paymentMethodBreakdown;
  final String period;

  ExpenseResponse({
    required this.totalExpenses,
    required this.categoryBreakdown,
    required this.paymentMethodBreakdown,
    required this.period,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ExpenseResponse(
      totalExpenses: (data['totalExpenses'] as num).toDouble(),
      categoryBreakdown: data['categoryBreakdown'] as List? ?? [],
      paymentMethodBreakdown:
          data['paymentMethodBreakdown'] as List? ?? [],
      period: data['period'] as String,
    );
  }
}

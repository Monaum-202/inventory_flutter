class StockItem {
  final String productName;
  final double stockAmount;

  StockItem({
    required this.productName,
    required this.stockAmount,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      productName: json['productName'] as String,
      stockAmount: (json['stockAmount'] as num).toDouble(),
    );
  }
}

class StockResponse {
  final List<StockItem> stocks;

  StockResponse({required this.stocks});

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;
    return StockResponse(
      stocks: data.map((item) => StockItem.fromJson(item)).toList(),
    );
  }
}

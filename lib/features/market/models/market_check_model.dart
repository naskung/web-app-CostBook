import 'package:equatable/equatable.dart';

double _number(Object? value) => (value as num? ?? 0).toDouble();

class MarketCostItemModel extends Equatable {
  const MarketCostItemModel({required this.name, this.amount = 0, this.note = ''});

  final String name;
  final double amount;
  final String note;

  factory MarketCostItemModel.fromJson(Map<String, dynamic> json) {
    return MarketCostItemModel(
      name: json['name'] as String? ?? '',
      amount: _number(json['amount']),
      note: json['note'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [name, amount, note];
}

class MarketSourceModel extends Equatable {
  const MarketSourceModel({required this.url, this.title = '', this.price = 0, this.kind = retail});

  static const String retail = 'retail';
  static const String wholesale = 'wholesale';
  static const String material = 'material';

  final String url;
  final String title;
  final double price;
  final String kind;

  factory MarketSourceModel.fromJson(Map<String, dynamic> json) {
    return MarketSourceModel(
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: _number(json['price']),
      kind: json['kind'] as String? ?? retail,
    );
  }

  @override
  List<Object?> get props => [url, title, price, kind];
}

class MarketCheckModel extends Equatable {
  const MarketCheckModel({
    required this.id,
    required this.productId,
    this.ourCostPrice = 0,
    this.ourSellPrice = 0,
    this.summary = '',
    this.retailLow = 0,
    this.retailHigh = 0,
    this.retailTypical = 0,
    this.wholesaleLow = 0,
    this.wholesaleHigh = 0,
    this.wholesaleNote = '',
    this.marketCost = 0,
    this.costItems = const [],
    this.suggestedPrice = 0,
    this.advice = '',
    this.confidence = 'low',
    this.sources = const [],
    this.checkedAt,
  });

  final String id;
  final String productId;
  final double ourCostPrice;
  final double ourSellPrice;
  final String summary;
  final double retailLow;
  final double retailHigh;
  final double retailTypical;
  final double wholesaleLow;
  final double wholesaleHigh;
  final String wholesaleNote;
  final double marketCost;
  final List<MarketCostItemModel> costItems;
  final double suggestedPrice;
  final String advice;
  final String confidence;
  final List<MarketSourceModel> sources;
  final DateTime? checkedAt;

  bool get hasRetail => retailLow > 0 || retailHigh > 0;

  bool get hasWholesale => wholesaleLow > 0 || wholesaleHigh > 0;

  int daysOld(DateTime now) {
    final checked = checkedAt;
    if (checked == null) return 0;
    return now.difference(checked).inDays;
  }

  factory MarketCheckModel.fromJson(Map<String, dynamic> json) {
    final costItems = json['cost_items'] as List? ?? [];
    final sources = json['sources'] as List? ?? [];
    return MarketCheckModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      ourCostPrice: _number(json['our_cost_price']),
      ourSellPrice: _number(json['our_sell_price']),
      summary: json['summary'] as String? ?? '',
      retailLow: _number(json['retail_low']),
      retailHigh: _number(json['retail_high']),
      retailTypical: _number(json['retail_typical']),
      wholesaleLow: _number(json['wholesale_low']),
      wholesaleHigh: _number(json['wholesale_high']),
      wholesaleNote: json['wholesale_note'] as String? ?? '',
      marketCost: _number(json['market_cost']),
      costItems: costItems.map((item) => MarketCostItemModel.fromJson(item as Map<String, dynamic>)).toList(),
      suggestedPrice: _number(json['suggested_price']),
      advice: json['advice'] as String? ?? '',
      confidence: json['confidence'] as String? ?? 'low',
      sources: sources.map((item) => MarketSourceModel.fromJson(item as Map<String, dynamic>)).toList(),
      checkedAt: DateTime.tryParse(json['checked_at'] as String? ?? '')?.toLocal(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    ourCostPrice,
    ourSellPrice,
    summary,
    retailLow,
    retailHigh,
    retailTypical,
    wholesaleLow,
    wholesaleHigh,
    wholesaleNote,
    marketCost,
    costItems,
    suggestedPrice,
    advice,
    confidence,
    sources,
    checkedAt,
  ];
}

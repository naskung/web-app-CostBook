import 'package:equatable/equatable.dart';

double _number(Object? value) => (value as num? ?? 0).toDouble();

int _integer(Object? value) => (value as num? ?? 0).toInt();

class SalesSummaryModel extends Equatable {
  const SalesSummaryModel({
    this.netSales = 0,
    this.cost = 0,
    this.grossProfit = 0,
    this.grossMargin = 0,
    this.vat = 0,
    this.discount = 0,
    this.itemsSold = 0,
    this.averageBill = 0,
  });

  final double netSales;
  final double cost;
  final double grossProfit;
  final double grossMargin;
  final double vat;
  final double discount;
  final int itemsSold;
  final double averageBill;

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalesSummaryModel(
      netSales: _number(json['net_sales']),
      cost: _number(json['cost']),
      grossProfit: _number(json['gross_profit']),
      grossMargin: _number(json['gross_margin']),
      vat: _number(json['vat']),
      discount: _number(json['discount']),
      itemsSold: _integer(json['items_sold']),
      averageBill: _number(json['average_bill']),
    );
  }

  @override
  List<Object?> get props => [netSales, cost, grossProfit, grossMargin, vat, discount, itemsSold, averageBill];
}

class MonthTotalsModel extends Equatable {
  const MonthTotalsModel({
    this.month = '',
    this.income = 0,
    this.expense = 0,
    this.profit = 0,
    this.netSales = 0,
    this.bills = 0,
    this.grossProfit = 0,
  });

  final String month;
  final double income;
  final double expense;
  final double profit;
  final double netSales;
  final int bills;
  final double grossProfit;

  DateTime? get monthDate => DateTime.tryParse('$month-01');

  factory MonthTotalsModel.fromJson(Map<String, dynamic> json) {
    return MonthTotalsModel(
      month: json['month'] as String? ?? '',
      income: _number(json['income']),
      expense: _number(json['expense']),
      profit: _number(json['profit']),
      netSales: _number(json['net_sales']),
      bills: _integer(json['bills']),
      grossProfit: _number(json['gross_profit']),
    );
  }

  @override
  List<Object?> get props => [month, income, expense, profit, netSales, bills, grossProfit];
}

class DailySalesModel extends Equatable {
  const DailySalesModel({required this.date, this.netSales = 0, this.bills = 0});

  final String date;
  final double netSales;
  final int bills;

  int get day => DateTime.tryParse(date)?.day ?? 0;

  int get weekdayIndex => (DateTime.tryParse(date)?.weekday ?? 7) % 7;

  factory DailySalesModel.fromJson(Map<String, dynamic> json) {
    return DailySalesModel(
      date: json['date'] as String? ?? '',
      netSales: _number(json['net_sales']),
      bills: _integer(json['bills']),
    );
  }

  @override
  List<Object?> get props => [date, netSales, bills];
}

class ProductSalesModel extends Equatable {
  const ProductSalesModel({
    required this.productId,
    required this.name,
    this.unit = '',
    this.quantity = 0,
    this.netSales = 0,
    this.cost = 0,
    this.profit = 0,
    this.margin = 0,
  });

  final String productId;
  final String name;
  final String unit;
  final int quantity;
  final double netSales;
  final double cost;
  final double profit;
  final double margin;

  factory ProductSalesModel.fromJson(Map<String, dynamic> json) {
    return ProductSalesModel(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantity: _integer(json['quantity']),
      netSales: _number(json['net_sales']),
      cost: _number(json['cost']),
      profit: _number(json['profit']),
      margin: _number(json['margin']),
    );
  }

  @override
  List<Object?> get props => [productId, name, unit, quantity, netSales, cost, profit, margin];
}

class CategoryAmountModel extends Equatable {
  const CategoryAmountModel({required this.category, this.amount = 0, this.percent = 0});

  final String category;
  final double amount;
  final double percent;

  factory CategoryAmountModel.fromJson(Map<String, dynamic> json) {
    return CategoryAmountModel(
      category: json['category'] as String? ?? '',
      amount: _number(json['amount']),
      percent: _number(json['percent']),
    );
  }

  @override
  List<Object?> get props => [category, amount, percent];
}

class StockValueModel extends Equatable {
  const StockValueModel({this.costValue = 0, this.retailValue = 0, this.outOfStock = 0});

  final double costValue;
  final double retailValue;
  final int outOfStock;

  factory StockValueModel.fromJson(Map<String, dynamic> json) {
    return StockValueModel(
      costValue: _number(json['cost_value']),
      retailValue: _number(json['retail_value']),
      outOfStock: _integer(json['out_of_stock']),
    );
  }

  @override
  List<Object?> get props => [costValue, retailValue, outOfStock];
}

class MarketPositionModel extends Equatable {
  const MarketPositionModel({
    required this.productId,
    required this.name,
    this.customerPrice = 0,
    this.retailLow = 0,
    this.retailHigh = 0,
    this.retailTypical = 0,
    this.position = 'unknown',
    this.diffPercent = 0,
    this.checkedAt,
  });

  final String productId;
  final String name;
  final double customerPrice;
  final double retailLow;
  final double retailHigh;
  final double retailTypical;
  final String position;
  final double diffPercent;
  final DateTime? checkedAt;

  factory MarketPositionModel.fromJson(Map<String, dynamic> json) {
    return MarketPositionModel(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      customerPrice: _number(json['customer_price']),
      retailLow: _number(json['retail_low']),
      retailHigh: _number(json['retail_high']),
      retailTypical: _number(json['retail_typical']),
      position: json['position'] as String? ?? 'unknown',
      diffPercent: _number(json['diff_percent']),
      checkedAt: DateTime.tryParse(json['checked_at'] as String? ?? '')?.toLocal(),
    );
  }

  @override
  List<Object?> get props => [
    productId,
    name,
    customerPrice,
    retailLow,
    retailHigh,
    retailTypical,
    position,
    diffPercent,
    checkedAt,
  ];
}

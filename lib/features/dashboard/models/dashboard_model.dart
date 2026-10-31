import 'package:equatable/equatable.dart';

class LowStockItemModel extends Equatable {
  const LowStockItemModel({
    required this.productId,
    required this.name,
    this.unit = '',
    this.stock = 0,
    this.minStock = 0,
  });

  final String productId;
  final String name;
  final String unit;
  final int stock;
  final int minStock;

  factory LowStockItemModel.fromJson(Map<String, dynamic> json) {
    return LowStockItemModel(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      stock: (json['stock'] as num? ?? 0).toInt(),
      minStock: (json['min_stock'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'name': name, 'unit': unit, 'stock': stock, 'min_stock': minStock};
  }

  @override
  List<Object?> get props => [productId, name, unit, stock, minStock];
}

class DashboardModel extends Equatable {
  const DashboardModel({
    this.income = 0,
    this.expense = 0,
    this.profit = 0,
    this.invoiceCount = 0,
    this.invoiceTotal = 0,
    this.productCount = 0,
    this.lowStockCount = 0,
    this.lowStock = const [],
  });

  final double income;
  final double expense;
  final double profit;
  final int invoiceCount;
  final double invoiceTotal;
  final int productCount;
  final int lowStockCount;
  final List<LowStockItemModel> lowStock;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final lowStock = json['low_stock'] as List? ?? [];
    return DashboardModel(
      income: (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] as num? ?? 0).toDouble(),
      profit: (json['profit'] as num? ?? 0).toDouble(),
      invoiceCount: (json['invoice_count'] as num? ?? 0).toInt(),
      invoiceTotal: (json['invoice_total'] as num? ?? 0).toDouble(),
      productCount: (json['product_count'] as num? ?? 0).toInt(),
      lowStockCount: (json['low_stock_count'] as num? ?? 0).toInt(),
      lowStock: lowStock.map((item) => LowStockItemModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'income': income,
      'expense': expense,
      'profit': profit,
      'invoice_count': invoiceCount,
      'invoice_total': invoiceTotal,
      'product_count': productCount,
      'low_stock_count': lowStockCount,
      'low_stock': lowStock.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    income,
    expense,
    profit,
    invoiceCount,
    invoiceTotal,
    productCount,
    lowStockCount,
    lowStock,
  ];
}

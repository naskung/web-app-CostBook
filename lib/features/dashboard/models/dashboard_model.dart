import 'package:equatable/equatable.dart';

import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';

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
    this.sales = const SalesSummaryModel(),
    this.previous = const MonthTotalsModel(),
    this.monthlyTrend = const [],
    this.dailySales = const [],
    this.previousDailySales = const [],
    this.topProducts = const [],
    this.categorySales = const [],
    this.expenseByCategory = const [],
    this.stock = const StockValueModel(),
    this.market = const [],
  });

  final double income;
  final double expense;
  final double profit;
  final int invoiceCount;
  final double invoiceTotal;
  final int productCount;
  final int lowStockCount;
  final List<LowStockItemModel> lowStock;
  final SalesSummaryModel sales;
  final MonthTotalsModel previous;
  final List<MonthTotalsModel> monthlyTrend;
  final List<DailySalesModel> dailySales;
  final List<DailySalesModel> previousDailySales;
  final List<ProductSalesModel> topProducts;
  final List<CategoryAmountModel> categorySales;
  final List<CategoryAmountModel> expenseByCategory;
  final StockValueModel stock;
  final List<MarketPositionModel> market;

  bool get hasSales => invoiceCount > 0;

  bool get hasTrend => monthlyTrend.any((month) => month.income != 0 || month.expense != 0);

  List<double> get weekdaySales {
    final totals = List<double>.filled(7, 0);
    for (final day in dailySales) {
      totals[day.weekdayIndex] += day.netSales;
    }
    return totals.map(MoneyUtil.round2).toList();
  }

  List<CategoryAmountModel> get topCategories => categorySales.take(3).toList();

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      income: (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] as num? ?? 0).toDouble(),
      profit: (json['profit'] as num? ?? 0).toDouble(),
      invoiceCount: (json['invoice_count'] as num? ?? 0).toInt(),
      invoiceTotal: (json['invoice_total'] as num? ?? 0).toDouble(),
      productCount: (json['product_count'] as num? ?? 0).toInt(),
      lowStockCount: (json['low_stock_count'] as num? ?? 0).toInt(),
      lowStock: _list(json['low_stock'], LowStockItemModel.fromJson),
      sales: SalesSummaryModel.fromJson(json['sales'] as Map<String, dynamic>? ?? {}),
      previous: MonthTotalsModel.fromJson(json['previous'] as Map<String, dynamic>? ?? {}),
      monthlyTrend: _list(json['monthly_trend'], MonthTotalsModel.fromJson),
      dailySales: _list(json['daily_sales'], DailySalesModel.fromJson),
      previousDailySales: _list(json['previous_daily_sales'], DailySalesModel.fromJson),
      topProducts: _list(json['top_products'], ProductSalesModel.fromJson),
      categorySales: _list(json['category_sales'], CategoryAmountModel.fromJson),
      expenseByCategory: _list(json['expense_by_category'], CategoryAmountModel.fromJson),
      stock: StockValueModel.fromJson(json['stock'] as Map<String, dynamic>? ?? {}),
      market: _list(json['market'], MarketPositionModel.fromJson),
    );
  }

  static List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) fromJson) {
    final items = value as List? ?? [];
    return items.map((item) => fromJson(item as Map<String, dynamic>)).toList();
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
    sales,
    previous,
    monthlyTrend,
    dailySales,
    previousDailySales,
    topProducts,
    categorySales,
    expenseByCategory,
    stock,
    market,
  ];
}

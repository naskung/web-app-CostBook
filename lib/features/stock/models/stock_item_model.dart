import 'package:equatable/equatable.dart';

class StockItemModel extends Equatable {
  const StockItemModel({
    required this.productId,
    required this.name,
    this.unit = '',
    this.stock = 0,
    this.minStock = 0,
    this.isLow = false,
  });

  final String productId;
  final String name;
  final String unit;
  final int stock;
  final int minStock;
  final bool isLow;

  bool get isOut => stock <= 0;

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      stock: (json['stock'] as num? ?? 0).toInt(),
      minStock: (json['min_stock'] as num? ?? 0).toInt(),
      isLow: json['is_low'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'unit': unit,
      'stock': stock,
      'min_stock': minStock,
      'is_low': isLow,
    };
  }

  @override
  List<Object?> get props => [productId, name, unit, stock, minStock, isLow];
}

import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  const ProductModel({
    this.id = '',
    required this.name,
    this.unit = '',
    this.costPrice = 0,
    this.sellPrice = 0,
    this.stock = 0,
    this.minStock = 0,
    this.batchQuantity = 1,
  });

  final String id;
  final String name;
  final String unit;
  final double costPrice;
  final double sellPrice;
  final int stock;
  final int minStock;
  final int batchQuantity;

  bool get isNew => id.isEmpty;

  bool get isLowStock => stock <= minStock;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      costPrice: (json['cost_price'] as num? ?? 0).toDouble(),
      sellPrice: (json['sell_price'] as num? ?? 0).toDouble(),
      stock: (json['stock'] as num? ?? 0).toInt(),
      minStock: (json['min_stock'] as num? ?? 0).toInt(),
      batchQuantity: (json['batch_quantity'] as num? ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'stock': stock,
      'min_stock': minStock,
      'batch_quantity': batchQuantity,
    };
  }

  @override
  List<Object?> get props => [id, name, unit, costPrice, sellPrice, stock, minStock, batchQuantity];
}

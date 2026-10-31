import 'package:equatable/equatable.dart';

import 'package:costbook/core/constants/api_constants.dart';

class ProductModel extends Equatable {
  const ProductModel({
    this.id = '',
    this.code = '',
    required this.name,
    this.category = '',
    this.description = '',
    this.unit = '',
    this.costPrice = 0,
    this.sellPrice = 0,
    this.stock = 0,
    this.minStock = 0,
    this.batchQuantity = 1,
    this.trackStock = true,
    this.customFields = const {},
    this.imageVersion = 0,
  });

  final String id;
  final String code;
  final String name;
  final String category;
  final String description;
  final String unit;
  final double costPrice;
  final double sellPrice;
  final int stock;
  final int minStock;
  final int batchQuantity;
  final bool trackStock;
  final Map<String, String> customFields;

  // เวลาที่เปลี่ยนรูปล่าสุด (มาจาก API) 0 = ไม่มีรูป — แก้ผ่าน ProductRepository.uploadImage / deleteImage เท่านั้น
  final int imageVersion;

  bool get isNew => id.isEmpty;

  bool get hasImage => imageVersion > 0;

  String get imageUrl => hasImage ? ApiConstants.productImageUrl(id, imageVersion) : '';

  bool get isLowStock => trackStock && stock <= minStock;

  String fieldValue(String fieldId) => customFields[fieldId] ?? '';

  bool matches(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    final values = [name, code, category, description, ...customFields.values];
    return values.any((value) => value.toLowerCase().contains(text));
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final customFields = json['custom_fields'] as Map? ?? {};
    return ProductModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      costPrice: (json['cost_price'] as num? ?? 0).toDouble(),
      sellPrice: (json['sell_price'] as num? ?? 0).toDouble(),
      stock: (json['stock'] as num? ?? 0).toInt(),
      minStock: (json['min_stock'] as num? ?? 0).toInt(),
      batchQuantity: (json['batch_quantity'] as num? ?? 1).toInt(),
      trackStock: json['track_stock'] as bool? ?? true,
      customFields: customFields.map((key, value) => MapEntry(key.toString(), value.toString())),
      imageVersion: (json['image_version'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'description': description,
      'unit': unit,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'stock': stock,
      'min_stock': minStock,
      'batch_quantity': batchQuantity,
      'track_stock': trackStock,
      'custom_fields': customFields,
    };
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    category,
    description,
    unit,
    costPrice,
    sellPrice,
    stock,
    minStock,
    batchQuantity,
    trackStock,
    customFields,
    imageVersion,
  ];
}

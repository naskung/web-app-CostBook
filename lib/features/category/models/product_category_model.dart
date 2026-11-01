import 'package:equatable/equatable.dart';

// หมวดหมู่สินค้า (API /product-categories) / productCount = มีสินค้ากี่ตัวในหมวด
class ProductCategoryModel extends Equatable {
  const ProductCategoryModel({this.id = '', required this.name, this.productCount = 0});

  final String id;
  final String name;
  final int productCount;

  bool get isNew => id.isEmpty;

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      productCount: (json['product_count'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name};

  @override
  List<Object?> get props => [id, name, productCount];
}

import 'package:equatable/equatable.dart';

// จำนวนสินค้าทั้งร้าน (API /products/counts) ไว้ทำตัวเลขบนแท็บ ทั้งหมด / สินค้าขาย / วัสดุ และปุ่มเฉพาะใกล้หมด
class ProductCountsModel extends Equatable {
  const ProductCountsModel({this.all = 0, this.forSale = 0, this.material = 0, this.low = 0});

  final int all;
  final int forSale;
  final int material;
  final int low;

  factory ProductCountsModel.fromJson(Map<String, dynamic> json) {
    return ProductCountsModel(
      all: (json['all'] as num? ?? 0).toInt(),
      forSale: (json['for_sale'] as num? ?? 0).toInt(),
      material: (json['material'] as num? ?? 0).toInt(),
      low: (json['low'] as num? ?? 0).toInt(),
    );
  }

  @override
  List<Object?> get props => [all, forSale, material, low];
}

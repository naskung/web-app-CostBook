import 'package:equatable/equatable.dart';

class BarcodeProductModel extends Equatable {
  const BarcodeProductModel({required this.code, required this.name, this.brand = '', this.quantity = ''});

  final String code;
  final String name;
  final String brand;
  final String quantity;

  String get details => [brand, quantity].where((text) => text.isNotEmpty).join(' · ');

  factory BarcodeProductModel.fromJson(Map<String, dynamic> json) {
    return BarcodeProductModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'brand': brand, 'quantity': quantity};
  }

  @override
  List<Object?> get props => [code, name, brand, quantity];
}

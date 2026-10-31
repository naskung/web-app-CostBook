import 'package:equatable/equatable.dart';

class InvoiceItemModel extends Equatable {
  const InvoiceItemModel({
    this.id = '',
    required this.productId,
    required this.name,
    this.unit = '',
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  final String id;
  final String productId;
  final String name;
  final String unit;
  final int quantity;
  final double unitPrice;
  final double amount;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      unitPrice: (json['unit_price'] as num? ?? 0).toDouble(),
      amount: (json['amount'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'amount': amount,
    };
  }

  @override
  List<Object?> get props => [id, productId, name, unit, quantity, unitPrice, amount];
}

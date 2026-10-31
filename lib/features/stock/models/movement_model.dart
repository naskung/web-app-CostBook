import 'package:equatable/equatable.dart';

class MovementModel extends Equatable {
  const MovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.unit = '',
    required this.type,
    required this.quantity,
    this.note = '',
    this.invoiceNo = '',
    this.unitCost = 0,
    this.supplier = '',
    required this.createdAt,
  });

  static const String stockIn = 'in';
  static const String stockOut = 'out';

  final String id;
  final String productId;
  final String productName;
  final String unit;
  final String type;
  final int quantity;
  final String note;
  final String invoiceNo;
  final double unitCost;
  final String supplier;
  final DateTime createdAt;

  bool get isIn => type == stockIn;

  bool get isFromInvoice => invoiceNo.isNotEmpty;

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      type: json['type'] as String? ?? stockIn,
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      note: json['note'] as String? ?? '',
      invoiceNo: json['invoice_no'] as String? ?? '',
      unitCost: (json['unit_cost'] as num? ?? 0).toDouble(),
      supplier: json['supplier'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'unit': unit,
      'type': type,
      'quantity': quantity,
      'note': note,
      'invoice_no': invoiceNo,
      'unit_cost': unitCost,
      'supplier': supplier,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    unit,
    type,
    quantity,
    note,
    invoiceNo,
    unitCost,
    supplier,
    createdAt,
  ];
}

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
    this.isMaterial = false,
    required this.createdAt,
    this.hasProfit = false,
    this.saleAmount = 0,
    this.costAmount = 0,
    this.profit = 0,
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
  // ตัด / คืนวัสดุที่ใช้ผลิตสินค้าอื่นอัตโนมัติ (note บอกว่าใช้ผลิตอะไร)
  final bool isMaterial;
  final DateTime createdAt;
  // แถวที่ขายตามเอกสารที่ยังไม่ยกเลิก: ยอดขายก่อน VAT หลังเฉลี่ยส่วนลด / ต้นทุน ณ วันที่ขาย / กำไร (API คิดให้)
  final bool hasProfit;
  final double saleAmount;
  final double costAmount;
  final double profit;

  bool get isIn => type == stockIn;

  bool get isFromInvoice => invoiceNo.isNotEmpty;

  bool get isSale => isFromInvoice && !isIn && !isMaterial;

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
      isMaterial: json['is_material'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ?? DateTime(1970),
      hasProfit: json['has_profit'] as bool? ?? false,
      saleAmount: (json['sale_amount'] as num? ?? 0).toDouble(),
      costAmount: (json['cost_amount'] as num? ?? 0).toDouble(),
      profit: (json['profit'] as num? ?? 0).toDouble(),
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
      'is_material': isMaterial,
      'created_at': createdAt.toUtc().toIso8601String(),
      'has_profit': hasProfit,
      'sale_amount': saleAmount,
      'cost_amount': costAmount,
      'profit': profit,
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
    isMaterial,
    createdAt,
    hasProfit,
    saleAmount,
    costAmount,
    profit,
  ];
}

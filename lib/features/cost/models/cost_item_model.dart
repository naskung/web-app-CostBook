import 'package:equatable/equatable.dart';

class CostItemModel extends Equatable {
  const CostItemModel({
    this.id = '',
    this.materialId = '',
    required this.type,
    this.kind = fixed,
    required this.name,
    this.quantity = 1,
    this.unit = '',
    this.unitPrice = 0,
    this.percent = 0,
  });

  static const String material = 'material';
  static const String labor = 'labor';
  static const String overhead = 'overhead';
  static const List<String> types = [material, labor, overhead];

  static const String fixed = 'fixed';
  static const String percentKind = 'percent';

  final String id;
  // ไม่ว่าง = ใช้วัสดุจากสต็อก: ราคา / หน่วยมาจากวัสดุ (API อัปเดตเองเมื่อราคาวัสดุเปลี่ยน) + รับสินค้าเข้าแล้วตัดวัสดุ
  final String materialId;
  final String type;
  final String kind;
  final String name;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double percent;

  bool get isPercent => kind == percentKind;

  bool get isMaterial => materialId.isNotEmpty;

  factory CostItemModel.fromJson(Map<String, dynamic> json) {
    return CostItemModel(
      id: json['id'] as String? ?? '',
      materialId: json['material_id'] as String? ?? '',
      type: json['type'] as String? ?? material,
      kind: json['kind'] as String? ?? fixed,
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 1).toDouble(),
      unit: json['unit'] as String? ?? '',
      unitPrice: (json['unit_price'] as num? ?? 0).toDouble(),
      percent: (json['percent'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'type': type,
      'kind': kind,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'percent': percent,
    };
  }

  @override
  List<Object?> get props => [id, materialId, type, kind, name, quantity, unit, unitPrice, percent];
}

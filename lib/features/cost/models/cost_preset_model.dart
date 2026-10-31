import 'package:equatable/equatable.dart';

import 'package:costbook/features/cost/models/cost_item_model.dart';

class CostPresetModel extends Equatable {
  const CostPresetModel({
    this.id = '',
    required this.type,
    this.kind = CostItemModel.fixed,
    required this.name,
    this.unit = '',
    this.unitPrice = 0,
    this.percent = 0,
  });

  factory CostPresetModel.fromItem(CostItemModel item, {String id = ''}) {
    return CostPresetModel(
      id: id,
      type: item.type,
      kind: item.kind,
      name: item.name,
      unit: item.unit,
      unitPrice: item.unitPrice,
      percent: item.percent,
    );
  }

  final String id;
  final String type;
  final String kind;
  final String name;
  final String unit;
  final double unitPrice;
  final double percent;

  CostItemModel toItem({double quantity = 1}) {
    return CostItemModel(
      type: type,
      kind: kind,
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      percent: percent,
    );
  }

  factory CostPresetModel.fromJson(Map<String, dynamic> json) {
    return CostPresetModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? CostItemModel.material,
      kind: json['kind'] as String? ?? CostItemModel.fixed,
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      unitPrice: (json['unit_price'] as num? ?? 0).toDouble(),
      percent: (json['percent'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'kind': kind, 'name': name, 'unit': unit, 'unit_price': unitPrice, 'percent': percent};
  }

  @override
  List<Object?> get props => [id, type, kind, name, unit, unitPrice, percent];
}

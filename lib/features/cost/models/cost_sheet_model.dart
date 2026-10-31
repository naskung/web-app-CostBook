import 'package:equatable/equatable.dart';

import 'package:costbook/core/utils/cost_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';

class CostSheetModel extends Equatable {
  const CostSheetModel({
    required this.productId,
    this.productName = '',
    this.unit = '',
    this.batchQuantity = 1,
    this.costPrice = 0,
    this.sellPrice = 0,
    this.items = const [],
  });

  final String productId;
  final String productName;
  final String unit;
  final int batchQuantity;
  final double costPrice;
  final double sellPrice;
  final List<CostItemModel> items;

  List<CostItemModel> itemsOf(String type) {
    return items.where((item) => item.type == type).toList();
  }

  double get fixedTotal {
    final fixedItems = items.where((item) => !item.isPercent);
    return MoneyUtil.sum(
      fixedItems.map((item) => CostUtil.lineAmount(quantity: item.quantity, unitPrice: item.unitPrice)),
    );
  }

  double amountOf(CostItemModel item) {
    if (item.isPercent) return CostUtil.percentOf(base: fixedTotal, percent: item.percent);
    return CostUtil.lineAmount(quantity: item.quantity, unitPrice: item.unitPrice);
  }

  double totalOf(String type) {
    return MoneyUtil.sum(itemsOf(type).map(amountOf));
  }

  double get totalCost {
    return MoneyUtil.sum(CostItemModel.types.map(totalOf));
  }

  double get costPerUnit {
    return CostUtil.costPerUnit(
      material: totalOf(CostItemModel.material),
      labor: totalOf(CostItemModel.labor),
      overhead: totalOf(CostItemModel.overhead),
      quantity: batchQuantity,
    );
  }

  double netSellPrice({required bool priceHasVat}) {
    if (priceHasVat) return TaxUtil.priceBeforeVat(sellPrice);
    return sellPrice;
  }

  double profitPerUnit({required bool priceHasVat}) {
    return CostUtil.profitPerUnit(sellPrice: netSellPrice(priceHasVat: priceHasVat), cost: costPerUnit);
  }

  double markupPercent({required bool priceHasVat}) {
    return CostUtil.markupPercent(sellPrice: netSellPrice(priceHasVat: priceHasVat), cost: costPerUnit);
  }

  factory CostSheetModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    return CostSheetModel(
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      batchQuantity: (json['batch_quantity'] as num? ?? 1).toInt(),
      costPrice: (json['cost_price'] as num? ?? 0).toDouble(),
      sellPrice: (json['sell_price'] as num? ?? 0).toDouble(),
      items: items.map((item) => CostItemModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_quantity': batchQuantity,
      'sell_price': sellPrice,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  CostSheetModel copyWith({int? batchQuantity, double? sellPrice, List<CostItemModel>? items}) {
    return CostSheetModel(
      productId: productId,
      productName: productName,
      unit: unit,
      batchQuantity: batchQuantity ?? this.batchQuantity,
      costPrice: costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [productId, productName, unit, batchQuantity, costPrice, sellPrice, items];
}

part of 'cost_bloc.dart';

abstract class CostEvent {}

class CostPageOpened extends CostEvent {}

class CostProductSelected extends CostEvent {
  CostProductSelected(this.productId);

  final String productId;
}

class CostItemAdded extends CostEvent {
  CostItemAdded(this.item);

  final CostItemModel item;
}

class CostItemChanged extends CostEvent {
  CostItemChanged({required this.oldItem, required this.newItem});

  final CostItemModel oldItem;
  final CostItemModel newItem;
}

class CostItemRemoved extends CostEvent {
  CostItemRemoved(this.item);

  final CostItemModel item;
}

class CostBatchQuantityChanged extends CostEvent {
  CostBatchQuantityChanged(this.batchQuantity);

  final int batchQuantity;
}

class CostSellPriceChanged extends CostEvent {
  CostSellPriceChanged(this.sellPrice);

  final double sellPrice;
}

class CostMarkupApplied extends CostEvent {
  CostMarkupApplied(this.markupPercent, {this.priceHasVat = false});

  final double markupPercent;
  final bool priceHasVat;
}

class CostSheetSaved extends CostEvent {}

class CostPresetSaved extends CostEvent {
  CostPresetSaved(this.preset);

  final CostPresetModel preset;
}

class CostPresetDeleted extends CostEvent {
  CostPresetDeleted(this.id);

  final String id;
}

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
  CostMarkupApplied(this.markupPercent);

  final double markupPercent;
}

class CostSheetSaved extends CostEvent {}

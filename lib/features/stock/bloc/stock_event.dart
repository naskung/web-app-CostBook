part of 'stock_bloc.dart';

abstract class StockEvent {}

class StockRequested extends StockEvent {}

class StockFilterChanged extends StockEvent {
  StockFilterChanged({required this.onlyLow});

  final bool onlyLow;
}

class StockViewChanged extends StockEvent {
  StockViewChanged({required this.showHistory});

  final bool showHistory;
}

class StockMovementSaved extends StockEvent {
  StockMovementSaved({required this.type, required this.productId, required this.quantity, required this.note});

  final String type;
  final String productId;
  final int quantity;
  final String note;
}

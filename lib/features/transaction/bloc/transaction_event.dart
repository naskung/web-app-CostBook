part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class TransactionsRequested extends TransactionEvent {}

class TransactionMonthChanged extends TransactionEvent {
  TransactionMonthChanged(this.monthCount);

  final int monthCount;
}

class TransactionSaved extends TransactionEvent {
  TransactionSaved(this.transaction);

  final TransactionModel transaction;
}

class TransactionDeleted extends TransactionEvent {
  TransactionDeleted(this.id);

  final String id;
}

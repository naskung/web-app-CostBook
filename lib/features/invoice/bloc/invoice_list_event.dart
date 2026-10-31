part of 'invoice_list_bloc.dart';

abstract class InvoiceListEvent {}

class InvoicesRequested extends InvoiceListEvent {}

class InvoiceMonthChanged extends InvoiceListEvent {
  InvoiceMonthChanged(this.monthCount);

  final int monthCount;
}

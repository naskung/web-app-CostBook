part of 'invoice_form_bloc.dart';

abstract class InvoiceFormEvent {}

class InvoiceFormOpened extends InvoiceFormEvent {}

class InvoiceItemAdded extends InvoiceFormEvent {
  InvoiceItemAdded(this.productId);

  final String productId;
}

class InvoiceItemChanged extends InvoiceFormEvent {
  InvoiceItemChanged({required this.productId, required this.quantity, required this.unitPrice});

  final String productId;
  final int quantity;
  final double unitPrice;
}

class InvoiceItemRemoved extends InvoiceFormEvent {
  InvoiceItemRemoved(this.productId);

  final String productId;
}

class InvoiceFormSubmitted extends InvoiceFormEvent {
  InvoiceFormSubmitted(this.draft);

  final InvoiceDraftModel draft;
}

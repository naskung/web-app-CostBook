part of 'quotation_form_bloc.dart';

abstract class QuotationFormEvent {}

class QuotationFormOpened extends QuotationFormEvent {}

class QuotationItemAdded extends QuotationFormEvent {
  QuotationItemAdded(this.productId);

  final String productId;
}

class QuotationItemChanged extends QuotationFormEvent {
  QuotationItemChanged({required this.productId, required this.quantity, required this.unitPrice});

  final String productId;
  final int quantity;
  final double unitPrice;
}

class QuotationItemRemoved extends QuotationFormEvent {
  QuotationItemRemoved(this.productId);

  final String productId;
}

class QuotationDiscountChanged extends QuotationFormEvent {
  QuotationDiscountChanged(this.discount);

  final double discount;
}

class QuotationFormSubmitted extends QuotationFormEvent {
  QuotationFormSubmitted(this.draft);

  final QuotationDraftModel draft;
}

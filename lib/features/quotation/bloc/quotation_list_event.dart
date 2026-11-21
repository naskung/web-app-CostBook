part of 'quotation_list_bloc.dart';

abstract class QuotationListEvent {}

class QuotationsRequested extends QuotationListEvent {}

class QuotationsMoreRequested extends QuotationListEvent {}

class QuotationRangeChanged extends QuotationListEvent {
  QuotationRangeChanged(this.range);

  final DateTimeRange range;
}

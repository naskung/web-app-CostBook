part of 'quotation_detail_bloc.dart';

abstract class QuotationDetailEvent {}

class QuotationDetailRequested extends QuotationDetailEvent {}

class QuotationCancelRequested extends QuotationDetailEvent {}

part of 'invoice_list_bloc.dart';

class InvoiceListState extends Equatable {
  const InvoiceListState({
    required this.month,
    this.status = AppStatus.initial,
    this.invoices = const [],
    this.errorCode = '',
  });

  final DateTime month;
  final AppStatus status;
  final List<InvoiceSummaryModel> invoices;
  final String errorCode;

  InvoiceListState copyWith({
    DateTime? month,
    AppStatus? status,
    List<InvoiceSummaryModel>? invoices,
    String? errorCode,
  }) {
    return InvoiceListState(
      month: month ?? this.month,
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props => [month, status, invoices, errorCode];
}

part of 'invoice_detail_bloc.dart';

class InvoiceDetailState extends Equatable {
  const InvoiceDetailState({
    this.status = AppStatus.initial,
    this.invoice,
    this.errorCode = '',
    this.cancelStatus = AppStatus.initial,
    this.cancelErrorCode = '',
  });

  final AppStatus status;
  final InvoiceModel? invoice;
  final String errorCode;
  final AppStatus cancelStatus;
  final String cancelErrorCode;

  InvoiceDetailState copyWith({
    AppStatus? status,
    InvoiceModel? invoice,
    String? errorCode,
    AppStatus? cancelStatus,
    String? cancelErrorCode,
  }) {
    return InvoiceDetailState(
      status: status ?? this.status,
      invoice: invoice ?? this.invoice,
      errorCode: errorCode ?? this.errorCode,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      cancelErrorCode: cancelErrorCode ?? this.cancelErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, invoice, errorCode, cancelStatus, cancelErrorCode];
}

part of 'invoice_detail_bloc.dart';

class InvoiceDetailState extends Equatable {
  const InvoiceDetailState({
    this.status = AppStatus.initial,
    this.invoice,
    this.errorCode = '',
    this.cancelStatus = AppStatus.initial,
    this.cancelErrorCode = '',
    this.deliveryUpdateStatus = AppStatus.initial,
    this.deliveryErrorCode = '',
  });

  final AppStatus status;
  final InvoiceModel? invoice;
  final String errorCode;
  final AppStatus cancelStatus;
  final String cancelErrorCode;
  final AppStatus deliveryUpdateStatus;
  final String deliveryErrorCode;

  InvoiceDetailState copyWith({
    AppStatus? status,
    InvoiceModel? invoice,
    String? errorCode,
    AppStatus? cancelStatus,
    String? cancelErrorCode,
    AppStatus? deliveryUpdateStatus,
    String? deliveryErrorCode,
  }) {
    return InvoiceDetailState(
      status: status ?? this.status,
      invoice: invoice ?? this.invoice,
      errorCode: errorCode ?? this.errorCode,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      cancelErrorCode: cancelErrorCode ?? this.cancelErrorCode,
      deliveryUpdateStatus: deliveryUpdateStatus ?? this.deliveryUpdateStatus,
      deliveryErrorCode: deliveryErrorCode ?? this.deliveryErrorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    invoice,
    errorCode,
    cancelStatus,
    cancelErrorCode,
    deliveryUpdateStatus,
    deliveryErrorCode,
  ];
}

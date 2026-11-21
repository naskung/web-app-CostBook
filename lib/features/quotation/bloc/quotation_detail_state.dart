part of 'quotation_detail_bloc.dart';

class QuotationDetailState extends Equatable {
  const QuotationDetailState({
    this.status = AppStatus.initial,
    this.quotation,
    this.errorCode = '',
    this.cancelStatus = AppStatus.initial,
    this.cancelErrorCode = '',
  });

  final AppStatus status;
  final QuotationModel? quotation;
  final String errorCode;
  final AppStatus cancelStatus;
  final String cancelErrorCode;

  QuotationDetailState copyWith({
    AppStatus? status,
    QuotationModel? quotation,
    String? errorCode,
    AppStatus? cancelStatus,
    String? cancelErrorCode,
  }) {
    return QuotationDetailState(
      status: status ?? this.status,
      quotation: quotation ?? this.quotation,
      errorCode: errorCode ?? this.errorCode,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      cancelErrorCode: cancelErrorCode ?? this.cancelErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, quotation, errorCode, cancelStatus, cancelErrorCode];
}

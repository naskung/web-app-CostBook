part of 'transaction_bloc.dart';

class TransactionState extends Equatable {
  const TransactionState({
    required this.month,
    this.status = AppStatus.initial,
    this.transactions = const [],
    this.summary = const TransactionSummaryModel(),
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.deleteStatus = AppStatus.initial,
    this.deleteErrorCode = '',
  });

  final DateTime month;
  final AppStatus status;
  final List<TransactionModel> transactions;
  final TransactionSummaryModel summary;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus deleteStatus;
  final String deleteErrorCode;

  TransactionState copyWith({
    DateTime? month,
    AppStatus? status,
    List<TransactionModel>? transactions,
    TransactionSummaryModel? summary,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? deleteStatus,
    String? deleteErrorCode,
  }) {
    return TransactionState(
      month: month ?? this.month,
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deleteErrorCode: deleteErrorCode ?? this.deleteErrorCode,
    );
  }

  @override
  List<Object?> get props => [
    month,
    status,
    transactions,
    summary,
    errorCode,
    saveStatus,
    saveErrorCode,
    deleteStatus,
    deleteErrorCode,
  ];
}

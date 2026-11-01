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
    this.hasMore = false,
    this.moreStatus = AppStatus.initial,
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
  // ยังมีรายการที่ยังไม่ได้โหลดไหม / สถานะของการโหลดหน้าต่อไป
  final bool hasMore;
  final AppStatus moreStatus;

  // เลื่อนลงแล้วโหลดหน้าต่อไปเองได้ไหม (โหลดเพิ่มพัง → รอผู้ใช้กดลองใหม่ ไม่ยิงซ้ำเอง)
  bool get canLoadMore =>
      status == AppStatus.success && hasMore && moreStatus != AppStatus.loading && moreStatus != AppStatus.failure;

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
    bool? hasMore,
    AppStatus? moreStatus,
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
      hasMore: hasMore ?? this.hasMore,
      moreStatus: moreStatus ?? this.moreStatus,
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
    hasMore,
    moreStatus,
  ];
}

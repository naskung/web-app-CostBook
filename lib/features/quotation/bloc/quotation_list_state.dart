part of 'quotation_list_bloc.dart';

class QuotationListState extends Equatable {
  const QuotationListState({
    required this.range,
    this.status = AppStatus.initial,
    this.quotations = const [],
    this.errorCode = '',
    this.hasMore = false,
    this.moreStatus = AppStatus.initial,
  });

  final DateTimeRange range;
  final AppStatus status;
  final List<QuotationSummaryModel> quotations;
  final String errorCode;
  final bool hasMore;
  final AppStatus moreStatus;

  bool get canLoadMore =>
      status == AppStatus.success && hasMore && moreStatus != AppStatus.loading && moreStatus != AppStatus.failure;

  QuotationListState copyWith({
    DateTimeRange? range,
    AppStatus? status,
    List<QuotationSummaryModel>? quotations,
    String? errorCode,
    bool? hasMore,
    AppStatus? moreStatus,
  }) {
    return QuotationListState(
      range: range ?? this.range,
      status: status ?? this.status,
      quotations: quotations ?? this.quotations,
      errorCode: errorCode ?? this.errorCode,
      hasMore: hasMore ?? this.hasMore,
      moreStatus: moreStatus ?? this.moreStatus,
    );
  }

  @override
  List<Object?> get props => [range, status, quotations, errorCode, hasMore, moreStatus];
}

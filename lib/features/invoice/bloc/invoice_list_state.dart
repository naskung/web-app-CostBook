part of 'invoice_list_bloc.dart';

class InvoiceListState extends Equatable {
  const InvoiceListState({
    required this.month,
    this.status = AppStatus.initial,
    this.invoices = const [],
    this.errorCode = '',
    this.hasMore = false,
    this.moreStatus = AppStatus.initial,
  });

  final DateTime month;
  final AppStatus status;
  final List<InvoiceSummaryModel> invoices;
  final String errorCode;
  // ยังมีใบที่ยังไม่ได้โหลดไหม / สถานะของการโหลดหน้าต่อไป
  final bool hasMore;
  final AppStatus moreStatus;

  // เลื่อนลงแล้วโหลดหน้าต่อไปเองได้ไหม (โหลดเพิ่มพัง → รอผู้ใช้กดลองใหม่ ไม่ยิงซ้ำเอง)
  bool get canLoadMore =>
      status == AppStatus.success && hasMore && moreStatus != AppStatus.loading && moreStatus != AppStatus.failure;

  InvoiceListState copyWith({
    DateTime? month,
    AppStatus? status,
    List<InvoiceSummaryModel>? invoices,
    String? errorCode,
    bool? hasMore,
    AppStatus? moreStatus,
  }) {
    return InvoiceListState(
      month: month ?? this.month,
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      errorCode: errorCode ?? this.errorCode,
      hasMore: hasMore ?? this.hasMore,
      moreStatus: moreStatus ?? this.moreStatus,
    );
  }

  @override
  List<Object?> get props => [month, status, invoices, errorCode, hasMore, moreStatus];
}

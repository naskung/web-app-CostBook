part of 'category_bloc.dart';

class CategoryState extends Equatable {
  const CategoryState({
    this.status = AppStatus.initial,
    this.categories = const [],
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.deleteStatus = AppStatus.initial,
    this.deleteErrorCode = '',
    this.hasMore = false,
    this.moreStatus = AppStatus.initial,
  });

  final AppStatus status;
  final List<ProductCategoryModel> categories;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus deleteStatus;
  final String deleteErrorCode;
  // ยังมีหมวดที่ยังไม่ได้โหลดไหม / สถานะของการโหลดหน้าต่อไป
  final bool hasMore;
  final AppStatus moreStatus;

  // เลื่อนลงแล้วโหลดหน้าต่อไปเองได้ไหม (โหลดเพิ่มพัง → รอผู้ใช้กดลองใหม่ ไม่ยิงซ้ำเอง)
  bool get canLoadMore =>
      status == AppStatus.success && hasMore && moreStatus != AppStatus.loading && moreStatus != AppStatus.failure;

  CategoryState copyWith({
    AppStatus? status,
    List<ProductCategoryModel>? categories,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? deleteStatus,
    String? deleteErrorCode,
    bool? hasMore,
    AppStatus? moreStatus,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
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
    status,
    categories,
    errorCode,
    saveStatus,
    saveErrorCode,
    deleteStatus,
    deleteErrorCode,
    hasMore,
    moreStatus,
  ];
}

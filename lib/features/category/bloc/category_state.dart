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
  });

  final AppStatus status;
  final List<ProductCategoryModel> categories;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus deleteStatus;
  final String deleteErrorCode;

  CategoryState copyWith({
    AppStatus? status,
    List<ProductCategoryModel>? categories,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? deleteStatus,
    String? deleteErrorCode,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deleteErrorCode: deleteErrorCode ?? this.deleteErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorCode, saveStatus, saveErrorCode, deleteStatus, deleteErrorCode];
}

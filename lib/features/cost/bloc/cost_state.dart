part of 'cost_bloc.dart';

class CostState extends Equatable {
  const CostState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.sheetStatus = AppStatus.initial,
    this.sheet,
    this.isDirty = false,
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
  });

  final AppStatus status;
  final List<ProductModel> products;
  final AppStatus sheetStatus;
  final CostSheetModel? sheet;
  final bool isDirty;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;

  CostState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    AppStatus? sheetStatus,
    CostSheetModel? sheet,
    bool? isDirty,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
  }) {
    return CostState(
      status: status ?? this.status,
      products: products ?? this.products,
      sheetStatus: sheetStatus ?? this.sheetStatus,
      sheet: sheet ?? this.sheet,
      isDirty: isDirty ?? this.isDirty,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, products, sheetStatus, sheet, isDirty, errorCode, saveStatus, saveErrorCode];
}

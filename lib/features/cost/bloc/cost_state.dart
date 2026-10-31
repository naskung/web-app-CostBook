part of 'cost_bloc.dart';

class CostState extends Equatable {
  const CostState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.presets = const [],
    this.sheetStatus = AppStatus.initial,
    this.sheet,
    this.isDirty = false,
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.presetErrorCode = '',
  });

  final AppStatus status;
  final List<ProductModel> products;
  final List<CostPresetModel> presets;
  final AppStatus sheetStatus;
  final CostSheetModel? sheet;
  final bool isDirty;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final String presetErrorCode;

  CostState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    List<CostPresetModel>? presets,
    AppStatus? sheetStatus,
    CostSheetModel? sheet,
    bool? isDirty,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    String? presetErrorCode,
  }) {
    return CostState(
      status: status ?? this.status,
      products: products ?? this.products,
      presets: presets ?? this.presets,
      sheetStatus: sheetStatus ?? this.sheetStatus,
      sheet: sheet ?? this.sheet,
      isDirty: isDirty ?? this.isDirty,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      presetErrorCode: presetErrorCode ?? this.presetErrorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    presets,
    sheetStatus,
    sheet,
    isDirty,
    errorCode,
    saveStatus,
    saveErrorCode,
    presetErrorCode,
  ];
}

part of 'stock_bloc.dart';

class StockState extends Equatable {
  const StockState({
    this.status = AppStatus.initial,
    this.items = const [],
    this.movements = const [],
    this.onlyLow = false,
    this.showHistory = false,
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.savedType = '',
  });

  final AppStatus status;
  final List<StockItemModel> items;
  final List<MovementModel> movements;
  final bool onlyLow;
  final bool showHistory;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final String savedType;

  List<StockItemModel> get visibleItems {
    if (!onlyLow) return items;
    return items.where((item) => item.isLow).toList();
  }

  StockState copyWith({
    AppStatus? status,
    List<StockItemModel>? items,
    List<MovementModel>? movements,
    bool? onlyLow,
    bool? showHistory,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    String? savedType,
  }) {
    return StockState(
      status: status ?? this.status,
      items: items ?? this.items,
      movements: movements ?? this.movements,
      onlyLow: onlyLow ?? this.onlyLow,
      showHistory: showHistory ?? this.showHistory,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      savedType: savedType ?? this.savedType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    movements,
    onlyLow,
    showHistory,
    errorCode,
    saveStatus,
    saveErrorCode,
    savedType,
  ];
}

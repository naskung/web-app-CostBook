part of 'stock_bloc.dart';

// items = สินค้าที่นับสต็อก (คงเหลือ) / movements = ประวัติรับเข้า-เบิกออก ล่าสุดก่อน
// คงเหลือของสินค้าดูที่หน้ารายการสินค้า — หน้านี้เป็นประวัติสต็อก
class StockState extends Equatable {
  const StockState({
    this.status = AppStatus.initial,
    this.items = const [],
    this.movements = const [],
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.savedType = '',
  });

  final AppStatus status;
  final List<StockItemModel> items;
  final List<MovementModel> movements;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final String savedType;

  StockState copyWith({
    AppStatus? status,
    List<StockItemModel>? items,
    List<MovementModel>? movements,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    String? savedType,
  }) {
    return StockState(
      status: status ?? this.status,
      items: items ?? this.items,
      movements: movements ?? this.movements,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      savedType: savedType ?? this.savedType,
    );
  }

  @override
  List<Object?> get props => [status, items, movements, errorCode, saveStatus, saveErrorCode, savedType];
}

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
    this.saveErrorParams = const {},
    this.savedType = '',
  });

  final AppStatus status;
  final List<StockItemModel> items;
  final List<MovementModel> movements;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  // ค่าที่มากับ error เช่น วัสดุไม่พอ: ชื่อวัสดุ / ต้องใช้ / มีอยู่
  final Map<String, String> saveErrorParams;
  final String savedType;

  StockState copyWith({
    AppStatus? status,
    List<StockItemModel>? items,
    List<MovementModel>? movements,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    Map<String, String>? saveErrorParams,
    String? savedType,
  }) {
    return StockState(
      status: status ?? this.status,
      items: items ?? this.items,
      movements: movements ?? this.movements,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      saveErrorParams: saveErrorParams ?? this.saveErrorParams,
      savedType: savedType ?? this.savedType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    movements,
    errorCode,
    saveStatus,
    saveErrorCode,
    saveErrorParams,
    savedType,
  ];
}

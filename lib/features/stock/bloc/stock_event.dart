part of 'stock_bloc.dart';

abstract class StockEvent {}

// โหลดสินค้าที่นับสต็อก (ไว้เลือกในกล่องรับเข้า / เบิกออก) + ประวัติ
class StockRequested extends StockEvent {}

class StockMovementSaved extends StockEvent {
  StockMovementSaved({
    required this.type,
    required this.productId,
    required this.quantity,
    required this.note,
    this.unitCost = 0,
    this.supplier = '',
    this.skipMaterials = false,
  });

  final String type;
  final String productId;
  final int quantity;
  final String note;
  final double unitCost;
  final String supplier;
  // รับเข้าโดยไม่ตัดวัสดุตามใบต้นทุน (ของที่ทำไว้ก่อน)
  final bool skipMaterials;
}

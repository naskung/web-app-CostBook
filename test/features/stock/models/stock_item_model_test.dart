import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/stock/models/stock_item_model.dart';

void main() {
  const item = StockItemModel(productId: 'p1', name: 'กาแฟเย็น', unit: 'แก้ว', stock: 3, minStock: 5, isLow: true);

  group('StockItemModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {'product_id': 'p1', 'name': 'กาแฟเย็น', 'unit': 'แก้ว', 'stock': 3, 'min_stock': 5, 'is_low': true};
      expect(StockItemModel.fromJson(json), item);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(StockItemModel.fromJson(item.toJson()), item);
    });

    test('isOut เป็น true เมื่อคงเหลือ 0', () {
      expect(const StockItemModel(productId: 'p1', name: 'ชา').isOut, true);
      expect(item.isOut, false);
    });
  });
}

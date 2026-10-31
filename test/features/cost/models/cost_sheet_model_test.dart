import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_sheet_model.dart';

void main() {
  const sheet = CostSheetModel(
    productId: 'p1',
    productName: 'กาแฟเย็น',
    unit: 'แก้ว',
    batchQuantity: 20,
    costPrice: 25,
    sellPrice: 45,
    items: [
      CostItemModel(id: 'c1', type: 'material', name: 'เมล็ดกาแฟ', amount: 250),
      CostItemModel(id: 'c2', type: 'material', name: 'นมสด', amount: 120),
      CostItemModel(id: 'c3', type: 'labor', name: 'ค่าแรง', amount: 100),
      CostItemModel(id: 'c4', type: 'overhead', name: 'ค่าไฟ', amount: 30),
    ],
  );

  group('CostSheetModel', () {
    test('fromJson อ่านค่าและรายการต้นทุนได้ถูกต้อง', () {
      final json = {
        'product_id': 'p1',
        'product_name': 'กาแฟเย็น',
        'unit': 'แก้ว',
        'batch_quantity': 20,
        'cost_price': 25,
        'sell_price': 45,
        'items': [
          {'id': 'c1', 'type': 'material', 'name': 'เมล็ดกาแฟ', 'amount': 250},
          {'id': 'c2', 'type': 'material', 'name': 'นมสด', 'amount': 120},
          {'id': 'c3', 'type': 'labor', 'name': 'ค่าแรง', 'amount': 100},
          {'id': 'c4', 'type': 'overhead', 'name': 'ค่าไฟ', 'amount': 30},
        ],
      };
      expect(CostSheetModel.fromJson(json), sheet);
    });

    test('toJson ส่งแค่ batch_quantity, sell_price และรายการ (ไม่ส่ง id ของรายการ)', () {
      final json = sheet.toJson();
      expect(json['batch_quantity'], 20);
      expect(json['sell_price'], 45);
      expect((json['items'] as List).first, {'type': 'material', 'name': 'เมล็ดกาแฟ', 'amount': 250.0});
    });

    test('รวมวัตถุดิบ 250 + 120 = 370', () {
      expect(sheet.totalOf('material'), 370);
    });

    test('ต้นทุนรวมต่อรอบ 500 ผลิต 20 แก้ว ได้ต้นทุนต่อแก้ว 25', () {
      expect(sheet.totalCost, 500);
      expect(sheet.costPerUnit, 25);
    });

    test('ขาย 45 ทุน 25 กำไรแก้วละ 20 คิดเป็น markup 80%', () {
      expect(sheet.profitPerUnit, 20);
      expect(sheet.markupPercent, 80);
    });

    test('ผลิตได้ 0 ต้นทุนต่อหน่วยเป็น 0 ไม่ error', () {
      expect(sheet.copyWith(batchQuantity: 0).costPerUnit, 0);
    });
  });
}

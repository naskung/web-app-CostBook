import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_sheet_model.dart';

void main() {
  const pla = CostItemModel(id: 'c1', type: 'material', name: 'เส้น PLA', quantity: 160, unit: 'กรัม', unitPrice: 0.45);
  const labor = CostItemModel(id: 'c2', type: 'labor', name: 'ขัด + ประกอบ', quantity: 1, unit: 'ชม.', unitPrice: 60);
  const machine = CostItemModel(
    id: 'c3',
    type: 'overhead',
    name: 'ค่าเครื่อง',
    quantity: 10,
    unit: 'ชม.',
    unitPrice: 6,
  );
  const waste = CostItemModel(id: 'c4', type: 'overhead', kind: 'percent', name: 'เผื่อพิมพ์เสีย', percent: 10);
  const sheet = CostSheetModel(
    productId: 'p1',
    productName: 'เคสโทรศัพท์',
    unit: 'ชิ้น',
    batchQuantity: 4,
    costPrice: 52.8,
    sellPrice: 250,
    items: [pla, labor, machine, waste],
  );

  group('CostSheetModel', () {
    test('fromJson อ่านค่าและรายการต้นทุนได้ถูกต้อง', () {
      final json = {
        'product_id': 'p1',
        'product_name': 'เคสโทรศัพท์',
        'unit': 'ชิ้น',
        'batch_quantity': 4,
        'cost_price': 52.8,
        'sell_price': 250,
        'items': [
          {
            'id': 'c1',
            'type': 'material',
            'kind': 'fixed',
            'name': 'เส้น PLA',
            'quantity': 160,
            'unit': 'กรัม',
            'unit_price': 0.45,
          },
          {
            'id': 'c2',
            'type': 'labor',
            'kind': 'fixed',
            'name': 'ขัด + ประกอบ',
            'quantity': 1,
            'unit': 'ชม.',
            'unit_price': 60,
          },
          {
            'id': 'c3',
            'type': 'overhead',
            'kind': 'fixed',
            'name': 'ค่าเครื่อง',
            'quantity': 10,
            'unit': 'ชม.',
            'unit_price': 6,
          },
          {'id': 'c4', 'type': 'overhead', 'kind': 'percent', 'name': 'เผื่อพิมพ์เสีย', 'percent': 10},
        ],
      };
      expect(CostSheetModel.fromJson(json), sheet);
    });

    test('toJson ส่ง batch_quantity, sell_price และรายการ', () {
      final json = sheet.toJson();
      expect(json['batch_quantity'], 4);
      expect(json['sell_price'], 250);
      expect((json['items'] as List).length, 4);
    });

    test('บรรทัดแบบ จำนวน × ราคา: 160 กรัม × 0.45 = 72', () {
      expect(sheet.amountOf(pla), 72);
    });

    test('บรรทัดแบบ %: 10% ของ (72 + 60 + 60) = 19.20', () {
      expect(sheet.fixedTotal, 192);
      expect(sheet.amountOf(waste), 19.2);
    });

    test('รวมค่าใช้จ่ายอื่น = ค่าเครื่อง 60 + เผื่อเสีย 19.20 = 79.20', () {
      expect(sheet.totalOf('overhead'), 79.2);
    });

    test('ต้นทุนรวม 211.20 ผลิต 4 ชิ้น ได้ชิ้นละ 52.80', () {
      expect(sheet.totalCost, 211.2);
      expect(sheet.costPerUnit, 52.8);
    });

    test('ขาย 250 ทุน 52.80 กำไรชิ้นละ 197.20', () {
      expect(sheet.profitPerUnit(priceHasVat: false), 197.2);
    });

    test('ราคา 250 รวม VAT แล้ว: ร้านได้จริง 233.64 กำไร 180.84', () {
      expect(sheet.netSellPrice(priceHasVat: true), 233.64);
      expect(sheet.profitPerUnit(priceHasVat: true), 180.84);
    });

    test('markup คิดจากราคาที่ร้านได้จริง (ไม่รวม VAT)', () {
      final simple = sheet.copyWith(items: [labor], batchQuantity: 1, sellPrice: 107);
      expect(simple.markupPercent(priceHasVat: false), 78.33);
      expect(simple.markupPercent(priceHasVat: true), 66.67);
    });

    test('ผลิตได้ 0 ต้นทุนต่อหน่วยเป็น 0 ไม่ error', () {
      expect(sheet.copyWith(batchQuantity: 0).costPerUnit, 0);
    });
  });
}

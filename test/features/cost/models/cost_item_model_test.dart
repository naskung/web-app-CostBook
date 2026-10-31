import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/cost/models/cost_item_model.dart';

void main() {
  group('CostItemModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': 'c1',
        'type': 'material',
        'kind': 'fixed',
        'name': 'เส้น PLA',
        'quantity': 40,
        'unit': 'กรัม',
        'unit_price': 0.45,
        'percent': 0,
        'amount': 18,
      };
      expect(
        CostItemModel.fromJson(json),
        const CostItemModel(id: 'c1', type: 'material', name: 'เส้น PLA', quantity: 40, unit: 'กรัม', unitPrice: 0.45),
      );
    });

    test('toJson ไม่ส่ง id และ amount (API คิดจำนวนเงินเอง)', () {
      const item = CostItemModel(id: 'c1', type: 'overhead', kind: 'percent', name: 'เผื่อเสีย', percent: 10);
      expect(item.toJson(), {
        'type': 'overhead',
        'kind': 'percent',
        'name': 'เผื่อเสีย',
        'quantity': 1.0,
        'unit': '',
        'unit_price': 0.0,
        'percent': 10.0,
      });
    });

    test('ไม่มี kind (ข้อมูลเก่า) ถือเป็นแบบ จำนวน × ราคา', () {
      final item = CostItemModel.fromJson({'type': 'labor', 'name': 'ค่าแรง', 'unit_price': 100});
      expect(item.isPercent, false);
      expect(item.quantity, 1);
    });

    test('ประเภทต้นทุนมี 3 แบบ เรียง วัตถุดิบ ค่าแรง ค่าใช้จ่ายอื่น', () {
      expect(CostItemModel.types, ['material', 'labor', 'overhead']);
    });
  });
}

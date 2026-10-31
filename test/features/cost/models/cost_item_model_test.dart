import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/cost/models/cost_item_model.dart';

void main() {
  group('CostItemModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {'id': 'c1', 'type': 'labor', 'name': 'ค่าแรง', 'amount': 100};
      expect(
        CostItemModel.fromJson(json),
        const CostItemModel(id: 'c1', type: 'labor', name: 'ค่าแรง', amount: 100),
      );
    });

    test('toJson ไม่ส่ง id (API สร้าง id ใหม่ทุกครั้งที่บันทึกทั้งใบ)', () {
      const item = CostItemModel(id: 'c1', type: 'overhead', name: 'ค่าไฟ', amount: 30.5);
      expect(item.toJson(), {'type': 'overhead', 'name': 'ค่าไฟ', 'amount': 30.5});
    });

    test('ประเภทต้นทุนมี 3 แบบ เรียง วัตถุดิบ ค่าแรง ค่าใช้จ่ายอื่น', () {
      expect(CostItemModel.types, ['material', 'labor', 'overhead']);
    });
  });
}

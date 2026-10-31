import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';

void main() {
  const preset = CostPresetModel(id: 'p1', type: 'material', name: 'เส้น PLA', unit: 'กรัม', unitPrice: 0.45);

  group('CostPresetModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': 'p1',
        'type': 'material',
        'kind': 'fixed',
        'name': 'เส้น PLA',
        'unit': 'กรัม',
        'unit_price': 0.45,
        'percent': 0,
      };
      expect(CostPresetModel.fromJson(json), preset);
    });

    test('toJson ไม่ส่ง id', () {
      expect(preset.toJson().containsKey('id'), false);
      expect(preset.toJson()['unit_price'], 0.45);
    });

    test('สร้างจากบรรทัดต้นทุน ได้ชื่อ หน่วย ราคาเดิม (ไม่เก็บจำนวน)', () {
      const item = CostItemModel(type: 'overhead', name: 'ค่าเครื่อง', quantity: 2.5, unit: 'ชม.', unitPrice: 6);
      final fromItem = CostPresetModel.fromItem(item);
      expect([fromItem.name, fromItem.unit, fromItem.unitPrice], ['ค่าเครื่อง', 'ชม.', 6]);
    });

    test('เอาไปเป็นบรรทัดต้นทุน ได้จำนวนตามที่ส่ง', () {
      final item = preset.toItem(quantity: 40);
      expect([item.name, item.quantity, item.unitPrice], ['เส้น PLA', 40, 0.45]);
    });
  });
}

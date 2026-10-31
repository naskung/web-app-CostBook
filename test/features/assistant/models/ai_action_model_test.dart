import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/assistant/models/ai_action_model.dart';

void main() {
  final json = {
    'id': 't1',
    'type': 'update_product',
    'reason': 'ตลาดขาย 259–390',
    'product_id': 'p1',
    'product_name': 'เคสโทรศัพท์',
    'changes': [
      {'field': 'sell_price', 'from': 250, 'to': 290},
    ],
    'data': {'name': 'เคสโทรศัพท์', 'sell_price': 290, 'quantity': 10},
  };

  group('AiActionModel', () {
    test('fromJson อ่านงานที่ AI เสนอได้ สถานะเริ่มต้นคือรอยืนยัน', () {
      final action = AiActionModel.fromJson(json);
      expect(
        [action.id, action.type, action.productName, action.status],
        ['t1', AiActionModel.updateProduct, 'เคสโทรศัพท์', AiActionModel.pending],
      );
      expect(action.changes, [const AiChangeModel(field: 'sell_price', from: '250', to: '290')]);
      expect(action.isPending, true);
    });

    test('dataText / dataNumber อ่านค่าใน data ได้ ไม่มีค่า = ว่าง / 0', () {
      final action = AiActionModel.fromJson(json);
      expect(
        [action.dataNumber('sell_price'), action.dataNumber('unit_cost'), action.dataText('supplier')],
        [290, 0, ''],
      );
    });

    test('copyWith เปลี่ยนสถานะ ข้อมูลอื่นเหมือนเดิม', () {
      final action = AiActionModel.fromJson(json).copyWith(status: AiActionModel.running);
      expect([action.isRunning, action.productId], [true, 'p1']);
    });

    test('resultNote บอก AI ว่างานทำสำเร็จ / ไม่สำเร็จ / ผู้ใช้ไม่เอา', () {
      final action = AiActionModel.fromJson(json);
      expect(action.copyWith(status: AiActionModel.done).resultNote, contains('ทำสำเร็จ'));
      expect(
        action.copyWith(status: AiActionModel.failed, errorCode: 'stock_not_enough').resultNote,
        contains('stock_not_enough'),
      );
      expect(action.copyWith(status: AiActionModel.cancelled).resultNote, contains('ไม่เอา'));
    });
  });
}

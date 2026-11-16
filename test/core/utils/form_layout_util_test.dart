import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/product_form_block.dart';
import 'package:costbook/core/utils/form_layout_util.dart';

void main() {
  const blocks = ProductFormBlock.all;

  group('FormLayoutUtil.order', () {
    test('ยังไม่มีลำดับจาก API (API เก่า) = ช่องหลักแบบเดิม แล้วต่อด้วยช่องที่ร้านเพิ่ม', () {
      expect(FormLayoutUtil.order([], ['f1', 'f2']), [...blocks, 'f1', 'f2']);
    });

    test('ใช้ลำดับที่บันทึกไว้ (ช่องที่ร้านเพิ่มแทรกระหว่างช่องหลักได้)', () {
      final saved = ['image', 'name', 'f2', 'code_category', 'unit', 'prices', 'sale_stock', 'description', 'f1'];
      expect(FormLayoutUtil.order(saved, ['f1', 'f2']), saved);
    });

    test('ช่องที่ถูกลบไปแล้ว / key แปลก / ซ้ำ ตัดทิ้ง', () {
      final saved = [...blocks, 'deleted', 'f1', 'f1'];
      expect(FormLayoutUtil.order(saved, ['f1']), [...blocks, 'f1']);
    });

    test('ช่องที่เพิ่งเพิ่ม (ยังไม่อยู่ในลำดับ) ต่อท้ายสุด', () {
      expect(FormLayoutUtil.order([...blocks, 'f1'], ['f1', 'f2']), [...blocks, 'f1', 'f2']);
    });
  });

  group('FormLayoutUtil.moved', () {
    const keys = ['a', 'b', 'c', 'd'];

    test('ลากลง: newIndex ของ ReorderableListView นับรวมตำแหน่งเดิม', () {
      expect(FormLayoutUtil.moved(keys, 0, 3), ['b', 'c', 'a', 'd']);
      expect(FormLayoutUtil.moved(keys, 0, 4), ['b', 'c', 'd', 'a']);
    });

    test('ลากขึ้น', () {
      expect(FormLayoutUtil.moved(keys, 3, 1), ['a', 'd', 'b', 'c']);
    });

    test('ไม่แก้ list เดิม', () {
      FormLayoutUtil.moved(keys, 0, 2);
      expect(keys, ['a', 'b', 'c', 'd']);
    });
  });
}

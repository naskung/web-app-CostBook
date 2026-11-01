import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/page_util.dart';

void main() {
  test('ต่อหน้าใหม่ท้ายรายการ ตัวที่มีอยู่แล้ว (id ซ้ำ) ไม่เพิ่มซ้ำ', () {
    expect(PageUtil.append(['a', 'b'], ['b', 'c'], (id) => id), ['a', 'b', 'c']);
  });

  test('ได้ครบตามที่ขอ = อาจยังมีอีก / ได้น้อยกว่า = หมดแล้ว', () {
    expect(PageUtil.hasMore(20, 20), true);
    expect(PageUtil.hasMore(7, 20), false);
    expect(PageUtil.hasMore(0, 20), false);
  });

  test('โหลดใหม่หลังบันทึก: เท่าที่โหลดไว้ ไม่น้อยกว่า 1 หน้า ไม่เกิน 200', () {
    expect(PageUtil.reloadLimit(5), 20);
    expect(PageUtil.reloadLimit(45), 45);
    expect(PageUtil.reloadLimit(500), 200);
  });
}

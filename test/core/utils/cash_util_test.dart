import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/cash_util.dart';

void main() {
  test('ปุ่มลัด: พอดี + ปัดขึ้นเป็น 50 / 100 / 500 / 1,000 (ไม่ซ้ำ)', () {
    expect(CashUtil.quickAmounts(349.52), [349.52, 350, 400, 500, 1000]);
  });

  test('ยอดกลมอยู่แล้ว ไม่มีปุ่มซ้ำกับยอด', () {
    expect(CashUtil.quickAmounts(100), [100, 500, 1000]);
    expect(CashUtil.quickAmounts(1000), [1000]);
  });

  test('ยอดน้อย ๆ ได้ 50 / 100 / 500 / 1,000', () {
    expect(CashUtil.quickAmounts(35), [35, 50, 100, 500, 1000]);
  });

  test('เงินทอน = รับมา − ยอด (ปัด 2 ตำแหน่ง) / ติดลบ = เงินไม่พอ', () {
    expect(CashUtil.change(500, 349.52), 150.48);
    expect(CashUtil.change(300, 349.52), -49.52);
    expect(CashUtil.change(349.52, 349.52), 0);
  });
}

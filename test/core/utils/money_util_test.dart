import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/money_util.dart';

void main() {
  group('MoneyUtil.round2', () {
    test('10.456 ปัดขึ้นเป็น 10.46', () {
      expect(MoneyUtil.round2(10.456), 10.46);
    });

    test('10.454 ปัดลงเป็น 10.45', () {
      expect(MoneyUtil.round2(10.454), 10.45);
    });

    test('0.1 + 0.2 ได้ 0.3 พอดี', () {
      expect(MoneyUtil.round2(0.1 + 0.2), 0.3);
    });
  });

  group('MoneyUtil.format', () {
    test('1234.5 แสดงเป็น 1,234.50', () {
      expect(MoneyUtil.format(1234.5), '1,234.50');
    });

    test('0 แสดงเป็น 0.00', () {
      expect(MoneyUtil.format(0), '0.00');
    });

    test('ติดลบ -150.5 แสดงเป็น -150.50', () {
      expect(MoneyUtil.format(-150.5), '-150.50');
    });
  });

  group('MoneyUtil.parse', () {
    test('ข้อความ 1,234.50 ได้ 1234.5', () {
      expect(MoneyUtil.parse('1,234.50'), 1234.5);
    });

    test('มีช่องว่างหน้า-หลัง ยังอ่านได้', () {
      expect(MoneyUtil.parse(' 45 '), 45);
    });

    test('ข้อความที่ไม่ใช่ตัวเลข ได้ 0', () {
      expect(MoneyUtil.parse('abc'), 0);
    });
  });

  group('MoneyUtil.sum', () {
    test('0.1 + 0.1 + 0.1 ได้ 0.3 พอดี', () {
      expect(MoneyUtil.sum([0.1, 0.1, 0.1]), 0.3);
    });

    test('ไม่มีรายการ ได้ 0', () {
      expect(MoneyUtil.sum([]), 0);
    });
  });
}

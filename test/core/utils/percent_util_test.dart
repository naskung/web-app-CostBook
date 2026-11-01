import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/percent_util.dart';

void main() {
  group('PercentUtil.change', () {
    test('จาก 1,000 เป็น 1,250 เพิ่มขึ้น 25%', () {
      expect(PercentUtil.change(current: 1250, previous: 1000), 25);
    });

    test('จาก 1,000 เป็น 800 ลดลง 20%', () {
      expect(PercentUtil.change(current: 800, previous: 1000), -20);
    });

    test('เดือนก่อนเป็น 0 เทียบไม่ได้ ได้ null', () {
      expect(PercentUtil.change(current: 500, previous: 0), null);
    });

    test('ขาดทุนน้อยลง จาก -1,000 เป็น -500 = ดีขึ้น 50%', () {
      expect(PercentUtil.change(current: -500, previous: -1000), 50);
    });
  });

  group('PercentUtil.of', () {
    test('300 จาก 1,200 = 25%', () {
      expect(PercentUtil.of(part: 300, total: 1200), 25);
    });

    test('ทั้งหมดเป็น 0 ได้ 0 ไม่หารด้วย 0', () {
      expect(PercentUtil.of(part: 5, total: 0), 0);
    });
  });

  group('PercentUtil.format', () {
    test('12.345 แสดง 12.3%', () {
      expect(PercentUtil.format(12.345), '12.3%');
    });

    test('ใส่เครื่องหมาย + / -', () {
      expect([PercentUtil.format(5, showSign: true), PercentUtil.format(-3.47, showSign: true)], ['+5.0%', '-3.5%']);
    });

    test('ตั้งแต่ 100% ขึ้นไป ไม่มีทศนิยม', () {
      expect(PercentUtil.format(250.4), '250%');
    });
  });

  group('PercentUtil.fraction', () {
    test('25% = แถบยาว 0.25', () {
      expect(PercentUtil.fraction(25), 0.25);
    });

    test('ติดลบ (ขาดทุน) = แถบว่าง / เกิน 100% = เต็มแถบ', () {
      expect([PercentUtil.fraction(-5), PercentUtil.fraction(150)], [0, 1]);
    });
  });
}

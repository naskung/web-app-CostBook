import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/chart_util.dart';

void main() {
  group('ChartUtil.niceStep', () {
    test('ช่วง 0–1,355 แบ่ง 4 ช่อง ได้ช่องละ 500', () {
      expect(ChartUtil.niceStep(1355), 500);
    });

    test('ช่วง 0–80 ได้ช่องละ 20', () {
      expect(ChartUtil.niceStep(80), 20);
    });

    test('ช่วงเป็น 0 ได้ 1 ไม่ error', () {
      expect(ChartUtil.niceStep(0), 1);
    });
  });

  group('ChartUtil.range', () {
    test('ค่าบวกทั้งหมด เริ่มที่ 0 ปัดขึ้นเป็นเลขกลม', () {
      final range = ChartUtil.range([1355.14, 831.78, 0]);
      expect([range.min, range.max, range.step], [0, 1500, 500]);
    });

    test('มีค่าติดลบ (ขาดทุน) แกนต่ำกว่า 0', () {
      final range = ChartUtil.range([2340, -3520.5]);
      expect([range.min, range.max, range.step], [-4000, 4000, 2000]);
    });

    test('ไม่มีค่าเลย ได้ช่วง 0–1', () {
      final range = ChartUtil.range([]);
      expect([range.min, range.max], [0, 1]);
    });
  });

  group('ChartUtil.axisLabel', () {
    test('แกนไม่ถึง 10,000 แสดงเลขเต็ม', () {
      const range = ChartRange(min: 0, max: 1500, step: 500);
      expect(ChartUtil.axisLabel(1000, range), '1,000');
    });

    test('แกนถึง 10,000 ทุกเลขบนแกนใช้ K เหมือนกัน', () {
      const range = ChartRange(min: -5000, max: 10000, step: 5000);
      expect([-5000, 0, 5000, 10000].map((value) => ChartUtil.axisLabel(value.toDouble(), range)), [
        '-5K',
        '0',
        '5K',
        '10K',
      ]);
    });
  });

  group('ChartUtil.cumulative', () {
    test('ยอดสะสม 100, 0, 50.5 → 100, 100, 150.5', () {
      expect(ChartUtil.cumulative([100, 0, 50.5]), [100, 100, 150.5]);
    });

    test('ไม่มีข้อมูล ได้ list ว่าง', () {
      expect(ChartUtil.cumulative([]), []);
    });
  });
}

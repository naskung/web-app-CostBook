import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/utils/responsive_util.dart';

void main() {
  group('ResponsiveUtil.typeOf', () {
    test('จอกว้าง 375 เป็นมือถือ', () {
      expect(ResponsiveUtil.typeOf(375), ScreenType.mobile);
    });

    test('จอกว้าง 600 พอดี เป็นแท็บเล็ต', () {
      expect(ResponsiveUtil.typeOf(600), ScreenType.tablet);
    });

    test('จอกว้าง 1023 ยังเป็นแท็บเล็ต', () {
      expect(ResponsiveUtil.typeOf(1023), ScreenType.tablet);
    });

    test('จอกว้าง 1024 พอดี เป็นจอคอม', () {
      expect(ResponsiveUtil.typeOf(1024), ScreenType.desktop);
    });

    test('จอกว้าง 0 เป็นมือถือ (ไม่ error)', () {
      expect(ResponsiveUtil.typeOf(0), ScreenType.mobile);
    });
  });

  group('ResponsiveUtil.scaleOf', () {
    test('จอเล็กกว่า designWidth ไม่ขยาย ได้ 1', () {
      expect(ResponsiveUtil.scaleOf(1280), 1);
    });

    test('จอกว้างเท่า designWidth ได้ 1', () {
      expect(ResponsiveUtil.scaleOf(1440), 1);
    });

    test('จอกว้าง 2160 ขยาย 1.5 เท่า', () {
      expect(ResponsiveUtil.scaleOf(2160), 1.5);
    });

    test('จอกว้างมาก 5000 ขยายไม่เกิน maxScale (2 เท่า)', () {
      expect(ResponsiveUtil.scaleOf(5000), 2);
    });

    test('จอกว้าง 0 ได้ 1 (ไม่ error)', () {
      expect(ResponsiveUtil.scaleOf(0), 1);
    });
  });

  group('ResponsiveUtil.gridColumns', () {
    int columns(double width, int count) =>
        ResponsiveUtil.gridColumns(width: width, minItemWidth: 220, maxColumns: 4, count: count);

    test('จอกว้างพอ 4 คอลัมน์ การ์ด 4 ใบ อยู่แถวเดียว', () {
      expect(columns(1000, 4), 4);
    });

    test('จอพอ 3 คอลัมน์ การ์ด 4 ใบ → 2 × 2 ไม่ใช่ 3 + 1', () {
      expect(columns(752, 4), 2);
    });

    test('จอมือถือ ได้ 1 คอลัมน์', () {
      expect(columns(343, 4), 1);
    });

    test('การ์ดน้อยกว่าคอลัมน์ที่ใส่ได้ ใช้เท่าจำนวนการ์ด / ไม่มีการ์ด ไม่ error', () {
      expect(columns(1000, 2), 2);
      expect(columns(1000, 0), 1);
    });
  });
}

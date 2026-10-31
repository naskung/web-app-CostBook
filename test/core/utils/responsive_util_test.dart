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
}

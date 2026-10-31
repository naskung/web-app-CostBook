import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/validator_util.dart';

void main() {
  group('ValidatorUtil.required', () {
    test('ค่าว่าง ได้ข้อความ error', () {
      expect(ValidatorUtil.required(''), isNotNull);
    });

    test('มีแต่ช่องว่าง ได้ข้อความ error', () {
      expect(ValidatorUtil.required('   '), isNotNull);
    });

    test('null ได้ข้อความ error', () {
      expect(ValidatorUtil.required(null), isNotNull);
    });

    test('มีข้อความ ผ่าน (ได้ null)', () {
      expect(ValidatorUtil.required('abc'), isNull);
    });
  });

  group('ValidatorUtil.email', () {
    test('อีเมลถูกรูปแบบ ผ่าน (ได้ null)', () {
      expect(ValidatorUtil.email('user@costbook.com'), isNull);
    });

    test('อีเมลมีช่องว่างหน้า-หลัง ยังผ่าน', () {
      expect(ValidatorUtil.email('  user@costbook.com  '), isNull);
    });

    test('ค่าว่าง ได้ข้อความเดียวกับ required', () {
      expect(ValidatorUtil.email(''), ValidatorUtil.required(''));
    });

    test('ไม่มี @ ได้ข้อความ error', () {
      expect(ValidatorUtil.email('usercostbook.com'), isNotNull);
    });

    test('ไม่มีจุดหลัง @ ได้ข้อความ error', () {
      expect(ValidatorUtil.email('user@costbook'), isNotNull);
    });

    test('อีเมลผิดรูปแบบ ได้ข้อความต่างจาก required', () {
      expect(ValidatorUtil.email('abc'), isNot(ValidatorUtil.required('')));
    });
  });
}

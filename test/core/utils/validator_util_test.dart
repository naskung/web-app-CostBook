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

  group('ValidatorUtil.taxId', () {
    test('ไม่กรอก ผ่าน (ว่างได้)', () {
      expect(ValidatorUtil.taxId(''), isNull);
    });

    test('ตัวเลข 13 หลัก ผ่าน', () {
      expect(ValidatorUtil.taxId('0105555555555'), isNull);
    });

    test('12 หลัก ได้ข้อความ error', () {
      expect(ValidatorUtil.taxId('010555555555'), isNotNull);
    });

    test('มีขีด ได้ข้อความ error', () {
      expect(ValidatorUtil.taxId('0-1055-55555-55-5'), isNotNull);
    });
  });

  group('ValidatorUtil ตัวเลข', () {
    test('positiveNumber 45.50 ผ่าน', () {
      expect(ValidatorUtil.positiveNumber('45.50'), isNull);
    });

    test('positiveNumber 1,250 (มีลูกน้ำ) ผ่าน', () {
      expect(ValidatorUtil.positiveNumber('1,250'), isNull);
    });

    test('positiveNumber 0 ได้ข้อความ error', () {
      expect(ValidatorUtil.positiveNumber('0'), isNotNull);
    });

    test('positiveNumber ตัวอักษร ได้ข้อความ error', () {
      expect(ValidatorUtil.positiveNumber('abc'), isNotNull);
    });

    test('zeroOrMore ไม่กรอก ผ่าน (ถือเป็น 0)', () {
      expect(ValidatorUtil.zeroOrMore(''), isNull);
    });

    test('zeroOrMore 0 ผ่าน', () {
      expect(ValidatorUtil.zeroOrMore('0'), isNull);
    });

    test('zeroOrMore ติดลบ ได้ข้อความ error', () {
      expect(ValidatorUtil.zeroOrMore('-1'), isNotNull);
    });

    test('positiveInteger 3 ผ่าน', () {
      expect(ValidatorUtil.positiveInteger('3'), isNull);
    });

    test('positiveInteger 1.5 (ไม่ใช่จำนวนเต็ม) ได้ข้อความ error', () {
      expect(ValidatorUtil.positiveInteger('1.5'), isNotNull);
    });

    test('positiveInteger 0 ได้ข้อความ error', () {
      expect(ValidatorUtil.positiveInteger('0'), isNotNull);
    });
  });

  group('ValidatorUtil.password', () {
    test('ว่าง / สั้นกว่า 6 ตัว ได้ข้อความ error', () {
      expect(ValidatorUtil.password(''), isNotNull);
      expect(ValidatorUtil.password(null), isNotNull);
      expect(ValidatorUtil.password('12345'), isNotNull);
    });

    test('6 ตัวขึ้นไป ผ่าน / ภาษาไทยนับเป็นตัวอักษร (ตรงกับ API)', () {
      expect(ValidatorUtil.password('123456'), isNull);
      expect(ValidatorUtil.password('รหัสผ่าน'), isNull);
    });
  });

  group('ValidatorUtil.passwordMatch', () {
    test('ตรงกัน ผ่าน / ไม่ตรง ได้ข้อความ error', () {
      expect(ValidatorUtil.passwordMatch('abc123', 'abc123'), isNull);
      expect(ValidatorUtil.passwordMatch('abc124', 'abc123'), isNotNull);
      expect(ValidatorUtil.passwordMatch(null, 'abc123'), isNotNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/name_util.dart';

void main() {
  test('ชื่อไทย ได้ตัวแรก', () {
    expect(NameUtil.initialOf('สมชาย ใจดี'), 'ส');
  });

  test('ชื่อขึ้นต้นด้วยสระหน้า (เ แ โ ใ ไ) ได้สระ + พยัญชนะ', () {
    expect(NameUtil.initialOf('เอก'), 'เอ');
    expect(NameUtil.initialOf('ไพลิน'), 'ไพ');
  });

  test('ชื่ออังกฤษ ได้ตัวแรกเป็นตัวใหญ่ / มีช่องว่างหน้าชื่อไม่เป็นไร', () {
    expect(NameUtil.initialOf('  anna'), 'A');
  });

  test('ชื่อว่าง ได้ข้อความว่าง / มีแค่สระหน้าตัวเดียว ได้สระนั้น', () {
    expect(NameUtil.initialOf('   '), '');
    expect(NameUtil.initialOf('เ'), 'เ');
  });
}

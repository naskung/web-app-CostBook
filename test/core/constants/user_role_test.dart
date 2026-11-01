import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/user_role.dart';

void main() {
  test('แปลงชื่อจาก API เป็น role ได้ครบ', () {
    expect(UserRole.fromName('owner'), UserRole.owner);
    expect(UserRole.fromName('manager'), UserRole.manager);
    expect(UserRole.fromName('staff'), UserRole.staff);
  });

  test('role ที่ไม่รู้จัก / ไม่มี → staff (สิทธิ์น้อยสุด)', () {
    expect(UserRole.fromName('admin'), UserRole.staff);
    expect(UserRole.fromName(null), UserRole.staff);
  });

  test('key ข้อความของ role', () {
    expect(UserRole.manager.labelKey, 'role.manager');
  });
}

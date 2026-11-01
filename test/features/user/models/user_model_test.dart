import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/features/user/models/user_model.dart';

void main() {
  test('fromJson อ่านข้อมูลผู้ใช้จาก API ครบ', () {
    final user = UserModel.fromJson({
      'id': 'u1',
      'email': 'staff@costbook.com',
      'first_name': 'สมชาย',
      'last_name': 'ใจดี',
      'role': 'manager',
      'active': false,
      'avatar_version': 1767225600000,
    });
    expect(user.id, 'u1');
    expect(user.email, 'staff@costbook.com');
    expect(user.displayName, 'สมชาย ใจดี');
    expect(user.role, UserRole.manager);
    expect(user.isActive, false);
    expect(user.hasAvatar, true);
  });

  test('fromJson ของ /auth/me ไม่มี active → ถือว่าใช้งานได้ / ไม่มีรูป', () {
    final user = UserModel.fromJson({'id': 'u1', 'email': 'a@b.co', 'role': 'owner'});
    expect(user.isActive, true);
    expect(user.isOwner, true);
    expect(user.hasAvatar, false);
  });

  test('ยังไม่มีชื่อ ใช้อีเมลเป็นชื่อที่แสดง', () {
    expect(const UserModel(email: 'a@b.co').displayName, 'a@b.co');
  });

  test('toJson ส่งเฉพาะข้อมูลที่เจ้าของร้านแก้ได้', () {
    const user = UserModel(id: 'u1', email: 'a@b.co', firstName: 'ก', role: UserRole.staff, isActive: false);
    expect(user.toJson(), {'first_name': 'ก', 'last_name': '', 'role': 'staff', 'active': false});
  });

  test('id ว่าง = ผู้ใช้ใหม่', () {
    expect(const UserModel().isNew, true);
    expect(const UserModel(id: 'u1').isNew, false);
  });
}

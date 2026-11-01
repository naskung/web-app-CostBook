import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/repository/user_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient api;
  late UserRepository repository;

  final userJson = {'id': 'u1', 'email': 'a@b.co', 'first_name': 'ก', 'role': 'owner', 'avatar_version': 0};

  setUp(() {
    api = MockApiClient();
    repository = UserRepository(api);
  });

  test('getMe อ่านจาก /auth/me', () async {
    when(() => api.get('/auth/me')).thenAnswer((_) async => userJson);
    final user = await repository.getMe();
    expect(user.id, 'u1');
    expect(user.role, UserRole.owner);
  });

  test('updateProfile ส่งชื่อไป PUT /profile', () async {
    when(() => api.put('/profile', {'first_name': 'ข', 'last_name': 'ค'})).thenAnswer((_) async => userJson);
    await repository.updateProfile(firstName: 'ข', lastName: 'ค');
    verify(() => api.put('/profile', {'first_name': 'ข', 'last_name': 'ค'})).called(1);
  });

  test('changePassword ส่งรหัสเดิม + รหัสใหม่', () async {
    when(() => api.put(any(), any())).thenAnswer((_) async => null);
    await repository.changePassword(currentPassword: 'old123', newPassword: 'new123');
    verify(() => api.put('/profile/password', {'current_password': 'old123', 'new_password': 'new123'})).called(1);
  });

  test('uploadAvatar ส่งไฟล์ในช่อง avatar / deleteAvatar ได้ผู้ใช้ที่ไม่มีรูป', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    when(
      () => api.putFile('/profile/avatar', 'avatar', bytes, 'avatar.png'),
    ).thenAnswer((_) async => {...userJson, 'avatar_version': 9});
    when(() => api.delete('/profile/avatar')).thenAnswer((_) async => userJson);
    expect((await repository.uploadAvatar(bytes)).avatarVersion, 9);
    expect((await repository.deleteAvatar()).hasAvatar, false);
  });

  test('getUsers อ่านรายชื่อจาก /users', () async {
    when(() => api.get('/users')).thenAnswer((_) async => [userJson, userJson]);
    expect(await repository.getUsers(), hasLength(2));
  });

  test('createUser ส่งอีเมล + รหัสแรก / updateUser ส่งไป /users/:id', () async {
    when(() => api.post(any(), any())).thenAnswer((_) async => userJson);
    when(() => api.put(any(), any())).thenAnswer((_) async => userJson);
    const user = UserModel(id: 'u2', email: 'staff@b.co', firstName: 'ง', role: UserRole.staff);

    await repository.createUser(const UserModel(email: 'staff@b.co', firstName: 'ง'), '123456');
    final created = verify(() => api.post('/users', captureAny())).captured.single as Map<String, dynamic>;
    expect(created['email'], 'staff@b.co');
    expect(created['password'], '123456');
    expect(created['role'], 'staff');

    await repository.updateUser(user);
    verify(() => api.put('/users/u2', user.toJson())).called(1);
  });

  test('resetPassword ส่งรหัสใหม่ไป /users/:id/password', () async {
    when(() => api.put(any(), any())).thenAnswer((_) async => null);
    await repository.resetPassword('u2', 'abcdef');
    verify(() => api.put('/users/u2/password', {'new_password': 'abcdef'})).called(1);
  });
}

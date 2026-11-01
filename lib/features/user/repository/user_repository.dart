import 'dart:typed_data';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/user/models/user_model.dart';

class UserRepository {
  UserRepository(this.api);

  final ApiClient api;

  Future<UserModel> getMe() async {
    final data = await api.get('/auth/me') as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({required String firstName, required String lastName}) async {
    final data = await api.put('/profile', {'first_name': firstName, 'last_name': lastName}) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await api.put('/profile/password', {'current_password': currentPassword, 'new_password': newPassword});
  }

  Future<UserModel> uploadAvatar(Uint8List bytes) async {
    final data = await api.putFile('/profile/avatar', 'avatar', bytes, 'avatar.png') as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> deleteAvatar() async {
    final data = await api.delete('/profile/avatar') as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  // ---------- จัดการผู้ใช้ (เฉพาะเจ้าของร้าน — คนอื่นได้ error forbidden) ----------

  Future<List<UserModel>> getUsers() async => _users(await api.get('/users'));

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<UserModel>? cachedUsers() {
    final data = api.cached('/users');
    if (data == null) return null;
    return _users(data);
  }

  List<UserModel> _users(dynamic data) {
    return (data as List).map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> createUser(UserModel user, String password) async {
    await api.post('/users', {...user.toJson(), 'email': user.email, 'password': password});
  }

  Future<void> updateUser(UserModel user) async {
    await api.put('/users/${user.id}', user.toJson());
  }

  Future<void> resetPassword(String id, String newPassword) async {
    await api.put('/users/$id/password', {'new_password': newPassword});
  }
}

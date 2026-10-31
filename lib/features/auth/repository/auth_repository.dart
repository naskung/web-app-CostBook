import 'package:shared_preferences/shared_preferences.dart';

import 'package:costbook/core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this.api);

  static const String _tokenKey = 'token';

  final ApiClient api;

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final data = await api.post('/auth/login', {'email': email, 'password': password});
    ApiClient.token = data['token'] as String? ?? '';

    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(_tokenKey, ApiClient.token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  Future<void> logout() async {
    ApiClient.token = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    ApiClient.token = prefs.getString(_tokenKey) ?? '';
  }
}

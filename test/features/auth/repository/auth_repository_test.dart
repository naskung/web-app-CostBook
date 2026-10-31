import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiClient api;
  late AuthRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = MockApiClient();
    repository = AuthRepository(api);
    when(() => api.post('/auth/login', {'email': 'admin@costbook.com', 'password': '1234'}))
        .thenAnswer((_) async => {'token': 'abc', 'user': {'id': '1'}});
  });

  tearDown(() {
    ApiClient.token = '';
  });

  Future<String?> savedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  test('login แล้วได้ token เก็บไว้ใน ApiClient', () async {
    await repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: false);
    expect(ApiClient.token, 'abc');
  });

  test('login ติ๊กจดจำ เก็บ token ไว้ในเครื่อง', () async {
    await repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: true);
    expect(await savedToken(), 'abc');
  });

  test('login ไม่ติ๊กจดจำ ไม่เก็บ token และลบ token เก่าที่เคยจดจำไว้', () async {
    SharedPreferences.setMockInitialValues({'token': 'old'});
    await repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: false);
    expect(await savedToken(), isNull);
  });

  test('logout ลบ token ทั้งใน ApiClient และในเครื่อง', () async {
    await repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: true);
    await repository.logout();
    expect(ApiClient.token, '');
    expect(await savedToken(), isNull);
  });

  test('loadSavedToken อ่าน token ที่จดจำไว้ใส่ ApiClient', () async {
    SharedPreferences.setMockInitialValues({'token': 'saved'});
    await repository.loadSavedToken();
    expect(ApiClient.token, 'saved');
  });

  test('loadSavedToken ไม่เคยจดจำ ได้ token ว่าง', () async {
    await repository.loadSavedToken();
    expect(ApiClient.token, '');
  });

  test('login สำเร็จ เก็บอีเมลไว้ แม้ไม่ติ๊กจดจำ', () async {
    await repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: false);
    expect(await repository.loadSavedEmail(), 'admin@costbook.com');
  });

  test('login ไม่สำเร็จ ไม่เก็บอีเมล', () async {
    when(() => api.post('/auth/login', {'email': 'wrong@costbook.com', 'password': 'x'}))
        .thenThrow(Exception('invalid_credentials'));
    await expectLater(
      repository.login(email: 'wrong@costbook.com', password: 'x', rememberMe: false),
      throwsException,
    );
    expect(await repository.loadSavedEmail(), '');
  });

  test('logout แล้ว อีเมลที่เคยใช้ยังอยู่', () async {
    await repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: true);
    await repository.logout();
    expect(await repository.loadSavedEmail(), 'admin@costbook.com');
  });

  test('loadSavedEmail ไม่เคย login ได้ค่าว่าง', () async {
    expect(await repository.loadSavedEmail(), '');
  });
}

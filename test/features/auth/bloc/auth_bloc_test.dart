import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  void whenLogin(Future<void> Function() answer) {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        rememberMe: any(named: 'rememberMe'),
      ),
    ).thenAnswer((_) => answer());
  }

  LoginSubmitted loginEvent() {
    return LoginSubmitted(email: 'admin@costbook.com', password: '1234', rememberMe: true);
  }

  blocTest<AuthBloc, AuthState>(
    'LoginSubmitted สำเร็จ ได้ loading แล้ว success',
    build: () {
      whenLogin(() async {});
      return AuthBloc(repository);
    },
    act: (bloc) => bloc.add(loginEvent()),
    expect: () => [
      const AuthState(status: AppStatus.loading),
      const AuthState(status: AppStatus.success),
    ],
    verify: (_) {
      verify(() => repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: true)).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'LoginSubmitted รหัสผิด ได้ loading แล้ว failure พร้อม code invalid_credentials',
    build: () {
      whenLogin(() async => throw ApiException('invalid_credentials'));
      return AuthBloc(repository);
    },
    act: (bloc) => bloc.add(loginEvent()),
    expect: () => [
      const AuthState(status: AppStatus.loading),
      const AuthState(status: AppStatus.failure, errorCode: 'invalid_credentials'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'LoginSubmitted เจอ error อื่นที่ไม่ใช่ ApiException ได้ code unknown_error',
    build: () {
      whenLogin(() async => throw Exception('boom'));
      return AuthBloc(repository);
    },
    act: (bloc) => bloc.add(loginEvent()),
    expect: () => [
      const AuthState(status: AppStatus.loading),
      const AuthState(status: AppStatus.failure, errorCode: 'unknown_error'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'LogoutRequested เรียก logout แล้วได้ success',
    build: () {
      when(() => repository.logout()).thenAnswer((_) async {});
      return AuthBloc(repository);
    },
    act: (bloc) => bloc.add(LogoutRequested()),
    expect: () => [const AuthState(status: AppStatus.success)],
    verify: (_) {
      verify(() => repository.logout()).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'SavedEmailRequested ได้อีเมลที่เคยใช้ โดยสถานะยังเป็น initial (ไม่พาไปหน้าแรก)',
    build: () {
      when(() => repository.loadSavedEmail()).thenAnswer((_) async => 'admin@costbook.com');
      return AuthBloc(repository);
    },
    act: (bloc) => bloc.add(SavedEmailRequested()),
    expect: () => [const AuthState(savedEmail: 'admin@costbook.com')],
  );

  blocTest<AuthBloc, AuthState>(
    'SavedEmailRequested ไม่เคย login ไม่มี state ใหม่',
    build: () {
      when(() => repository.loadSavedEmail()).thenAnswer((_) async => '');
      return AuthBloc(repository);
    },
    act: (bloc) => bloc.add(SavedEmailRequested()),
    expect: () => <AuthState>[],
  );
}

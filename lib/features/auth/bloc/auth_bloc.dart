import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.repository) : super(const AuthState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository repository;

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AppStatus.loading));
    try {
      await repository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      emit(const AuthState(status: AppStatus.success));
    } on ApiException catch (e) {
      emit(AuthState(status: AppStatus.failure, errorCode: e.code));
    } catch (_) {
      emit(const AuthState(status: AppStatus.failure, errorCode: 'unknown_error'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthState(status: AppStatus.success));
  }
}

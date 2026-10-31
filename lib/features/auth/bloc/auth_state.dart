part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = AppStatus.initial,
    this.errorCode = '',
    this.savedEmail = '',
  });

  final AppStatus status;
  final String errorCode;
  final String savedEmail;

  @override
  List<Object?> get props => [status, errorCode, savedEmail];
}

part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = AppStatus.initial,
    this.errorCode = '',
  });

  final AppStatus status;
  final String errorCode;

  @override
  List<Object?> get props => [status, errorCode];
}

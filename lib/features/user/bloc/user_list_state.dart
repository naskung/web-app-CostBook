part of 'user_list_bloc.dart';

class UserListState extends Equatable {
  const UserListState({
    this.status = AppStatus.initial,
    this.users = const [],
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.resetStatus = AppStatus.initial,
    this.resetErrorCode = '',
  });

  final AppStatus status;
  final List<UserModel> users;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus resetStatus;
  final String resetErrorCode;

  UserListState copyWith({
    AppStatus? status,
    List<UserModel>? users,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? resetStatus,
    String? resetErrorCode,
  }) {
    return UserListState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      resetStatus: resetStatus ?? this.resetStatus,
      resetErrorCode: resetErrorCode ?? this.resetErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, users, errorCode, saveStatus, saveErrorCode, resetStatus, resetErrorCode];
}

part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = AppStatus.initial,
    this.user = const UserModel(),
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.passwordStatus = AppStatus.initial,
    this.passwordErrorCode = '',
    this.avatarStatus = AppStatus.initial,
    this.avatarErrorCode = '',
  });

  final AppStatus status;
  final UserModel user;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus passwordStatus;
  final String passwordErrorCode;
  final AppStatus avatarStatus;
  final String avatarErrorCode;

  ProfileState copyWith({
    AppStatus? status,
    UserModel? user,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? passwordStatus,
    String? passwordErrorCode,
    AppStatus? avatarStatus,
    String? avatarErrorCode,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      passwordStatus: passwordStatus ?? this.passwordStatus,
      passwordErrorCode: passwordErrorCode ?? this.passwordErrorCode,
      avatarStatus: avatarStatus ?? this.avatarStatus,
      avatarErrorCode: avatarErrorCode ?? this.avatarErrorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorCode,
    saveStatus,
    saveErrorCode,
    passwordStatus,
    passwordErrorCode,
    avatarStatus,
    avatarErrorCode,
  ];
}

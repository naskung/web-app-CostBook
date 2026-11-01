part of 'user_list_bloc.dart';

abstract class UserListEvent {}

class UsersRequested extends UserListEvent {}

class UserSaved extends UserListEvent {
  UserSaved(this.user, {this.password = ''});

  final UserModel user;
  final String password;
}

class UserPasswordReset extends UserListEvent {
  UserPasswordReset({required this.id, required this.password});

  final String id;
  final String password;
}

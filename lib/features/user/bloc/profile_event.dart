part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileRequested extends ProfileEvent {}

class ProfileSaved extends ProfileEvent {
  ProfileSaved({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;
}

class PasswordChanged extends ProfileEvent {
  PasswordChanged({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;
}

class AvatarUploaded extends ProfileEvent {
  AvatarUploaded(this.bytes);

  final Uint8List bytes;
}

class AvatarRemoved extends ProfileEvent {}

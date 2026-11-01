import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;

  const owner = UserModel(id: 'u1', email: 'a@b.co', firstName: 'สมชาย', role: UserRole.owner);
  const renamed = UserModel(id: 'u1', email: 'a@b.co', firstName: 'สมหญิง', role: UserRole.owner);
  const withPhoto = UserModel(id: 'u1', email: 'a@b.co', firstName: 'สมชาย', role: UserRole.owner, avatarVersion: 9);
  final bytes = Uint8List.fromList([1, 2, 3]);
  const loaded = ProfileState(status: AppStatus.success, user: owner);

  setUp(() => repository = MockUserRepository());

  blocTest<ProfileBloc, ProfileState>(
    'ProfileRequested สำเร็จ ได้ผู้ใช้ที่ login อยู่',
    build: () {
      when(() => repository.getMe()).thenAnswer((_) async => owner);
      return ProfileBloc(repository);
    },
    act: (bloc) => bloc.add(ProfileRequested()),
    expect: () => [const ProfileState(status: AppStatus.loading), loaded],
  );

  blocTest<ProfileBloc, ProfileState>(
    'ProfileRequested ล้มเหลว ได้ failure พร้อม code',
    build: () {
      when(() => repository.getMe()).thenThrow(ApiException('network_error'));
      return ProfileBloc(repository);
    },
    act: (bloc) => bloc.add(ProfileRequested()),
    expect:
        () => [
          const ProfileState(status: AppStatus.loading),
          const ProfileState(status: AppStatus.failure, errorCode: 'network_error'),
        ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'ProfileSaved สำเร็จ ได้ชื่อใหม่',
    build: () {
      when(() => repository.updateProfile(firstName: 'สมหญิง', lastName: '')).thenAnswer((_) async => renamed);
      return ProfileBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(ProfileSaved(firstName: 'สมหญิง', lastName: '')),
    expect:
        () => [
          loaded.copyWith(saveStatus: AppStatus.loading),
          loaded.copyWith(saveStatus: AppStatus.success, user: renamed),
        ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'PasswordChanged รหัสเดิมผิด ได้ failure password_current_invalid',
    build: () {
      when(
        () => repository.changePassword(currentPassword: 'wrong', newPassword: 'new123'),
      ).thenThrow(ApiException('password_current_invalid'));
      return ProfileBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(PasswordChanged(currentPassword: 'wrong', newPassword: 'new123')),
    expect:
        () => [
          loaded.copyWith(passwordStatus: AppStatus.loading),
          loaded.copyWith(passwordStatus: AppStatus.failure, passwordErrorCode: 'password_current_invalid'),
        ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'PasswordChanged สำเร็จ',
    build: () {
      when(() => repository.changePassword(currentPassword: 'old123', newPassword: 'new123')).thenAnswer((_) async {});
      return ProfileBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(PasswordChanged(currentPassword: 'old123', newPassword: 'new123')),
    expect:
        () => [loaded.copyWith(passwordStatus: AppStatus.loading), loaded.copyWith(passwordStatus: AppStatus.success)],
  );

  blocTest<ProfileBloc, ProfileState>(
    'AvatarUploaded สำเร็จ ได้ผู้ใช้ที่มีรูป (avatarVersion ใหม่)',
    build: () {
      when(() => repository.uploadAvatar(bytes)).thenAnswer((_) async => withPhoto);
      return ProfileBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(AvatarUploaded(bytes)),
    expect:
        () => [
          loaded.copyWith(avatarStatus: AppStatus.loading),
          loaded.copyWith(avatarStatus: AppStatus.success, user: withPhoto),
        ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'AvatarUploaded รูปใหญ่เกิน ได้ failure avatar_too_large',
    build: () {
      when(() => repository.uploadAvatar(bytes)).thenThrow(ApiException('avatar_too_large'));
      return ProfileBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(AvatarUploaded(bytes)),
    expect:
        () => [
          loaded.copyWith(avatarStatus: AppStatus.loading),
          loaded.copyWith(avatarStatus: AppStatus.failure, avatarErrorCode: 'avatar_too_large'),
        ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'AvatarRemoved สำเร็จ ได้ผู้ใช้ที่ไม่มีรูป',
    build: () {
      when(() => repository.deleteAvatar()).thenAnswer((_) async => owner);
      return ProfileBloc(repository);
    },
    seed: () => loaded.copyWith(user: withPhoto),
    act: (bloc) => bloc.add(AvatarRemoved()),
    expect:
        () => [
          loaded.copyWith(user: withPhoto, avatarStatus: AppStatus.loading),
          loaded.copyWith(avatarStatus: AppStatus.success),
        ],
  );
}

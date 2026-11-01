import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/user/bloc/user_list_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;

  const owner = UserModel(id: 'u1', email: 'a@b.co', firstName: 'สมชาย', role: UserRole.owner);
  const staff = UserModel(id: 'u2', email: 's@b.co', firstName: 'สมศรี', role: UserRole.staff);
  const newStaff = UserModel(email: 's@b.co', firstName: 'สมศรี', role: UserRole.staff);
  const loaded = UserListState(status: AppStatus.success, users: [owner]);

  setUpAll(() => registerFallbackValue(const UserModel()));

  setUp(() => repository = MockUserRepository());

  blocTest<UserListBloc, UserListState>(
    'UsersRequested สำเร็จ ได้รายชื่อผู้ใช้',
    build: () {
      when(() => repository.getUsers()).thenAnswer((_) async => [owner]);
      return UserListBloc(repository);
    },
    act: (bloc) => bloc.add(UsersRequested()),
    expect: () => [const UserListState(status: AppStatus.loading), loaded],
  );

  blocTest<UserListBloc, UserListState>(
    'UsersRequested ไม่ใช่เจ้าของร้าน ได้ failure forbidden',
    build: () {
      when(() => repository.getUsers()).thenThrow(ApiException('forbidden'));
      return UserListBloc(repository);
    },
    act: (bloc) => bloc.add(UsersRequested()),
    expect:
        () => [
          const UserListState(status: AppStatus.loading),
          const UserListState(status: AppStatus.failure, errorCode: 'forbidden'),
        ],
  );

  blocTest<UserListBloc, UserListState>(
    'UserSaved ผู้ใช้ใหม่ สร้างพร้อมรหัสแรก แล้วโหลดรายชื่อใหม่',
    build: () {
      when(() => repository.createUser(newStaff, '123456')).thenAnswer((_) async {});
      when(() => repository.getUsers()).thenAnswer((_) async => [owner, staff]);
      return UserListBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(UserSaved(newStaff, password: '123456')),
    expect:
        () => [
          loaded.copyWith(saveStatus: AppStatus.loading),
          loaded.copyWith(saveStatus: AppStatus.success, users: [owner, staff]),
        ],
    verify: (_) => verifyNever(() => repository.updateUser(any())),
  );

  blocTest<UserListBloc, UserListState>(
    'UserSaved ผู้ใช้เดิม แก้ข้อมูล (ไม่สร้างใหม่)',
    build: () {
      when(() => repository.updateUser(staff)).thenAnswer((_) async {});
      when(() => repository.getUsers()).thenAnswer((_) async => [owner, staff]);
      return UserListBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(UserSaved(staff)),
    expect:
        () => [
          loaded.copyWith(saveStatus: AppStatus.loading),
          loaded.copyWith(saveStatus: AppStatus.success, users: [owner, staff]),
        ],
    verify: (_) => verifyNever(() => repository.createUser(any(), any())),
  );

  blocTest<UserListBloc, UserListState>(
    'UserSaved ปลดเจ้าของคนสุดท้าย ได้ failure user_last_owner',
    build: () {
      when(() => repository.updateUser(any())).thenThrow(ApiException('user_last_owner'));
      return UserListBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(UserSaved(owner)),
    expect:
        () => [
          loaded.copyWith(saveStatus: AppStatus.loading),
          loaded.copyWith(saveStatus: AppStatus.failure, saveErrorCode: 'user_last_owner'),
        ],
  );

  blocTest<UserListBloc, UserListState>(
    'UserPasswordReset สำเร็จ',
    build: () {
      when(() => repository.resetPassword('u2', 'abcdef')).thenAnswer((_) async {});
      return UserListBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(UserPasswordReset(id: 'u2', password: 'abcdef')),
    expect: () => [loaded.copyWith(resetStatus: AppStatus.loading), loaded.copyWith(resetStatus: AppStatus.success)],
  );

  blocTest<UserListBloc, UserListState>(
    'UserPasswordReset ล้มเหลว ได้ failure พร้อม code',
    build: () {
      when(() => repository.resetPassword(any(), any())).thenThrow(ApiException('user_not_found'));
      return UserListBloc(repository);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(UserPasswordReset(id: 'u9', password: 'abcdef')),
    expect:
        () => [
          loaded.copyWith(resetStatus: AppStatus.loading),
          loaded.copyWith(resetStatus: AppStatus.failure, resetErrorCode: 'user_not_found'),
        ],
  );
}

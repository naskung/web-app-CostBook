import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/repository/user_repository.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

// หน้าจัดการผู้ใช้ (เจ้าของร้าน): เพิ่ม / แก้ชื่อ-role-เปิดปิดบัญชี / ตั้งรหัสผ่านใหม่ให้
class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc(this.repository) : super(const UserListState()) {
    on<UsersRequested>(_onRequested);
    on<UserSaved>(_onSaved);
    on<UserPasswordReset>(_onPasswordReset);
  }

  final UserRepository repository;

  Future<void> _onRequested(UsersRequested event, Emitter<UserListState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final users = await repository.getUsers();
      emit(state.copyWith(status: AppStatus.success, users: users));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  // ผู้ใช้ใหม่ต้องมี password (รหัสแรก) / ผู้ใช้เดิมไม่ใช้ password — เปลี่ยนรหัสใช้ UserPasswordReset
  Future<void> _onSaved(UserSaved event, Emitter<UserListState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      if (event.user.isNew) {
        await repository.createUser(event.user, event.password);
      } else {
        await repository.updateUser(event.user);
      }
      final users = await repository.getUsers();
      emit(state.copyWith(saveStatus: AppStatus.success, users: users));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onPasswordReset(UserPasswordReset event, Emitter<UserListState> emit) async {
    emit(state.copyWith(resetStatus: AppStatus.loading));
    try {
      await repository.resetPassword(event.id, event.password);
      emit(state.copyWith(resetStatus: AppStatus.success));
    } catch (error) {
      emit(state.copyWith(resetStatus: AppStatus.failure, resetErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}

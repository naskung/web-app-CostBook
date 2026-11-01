import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/repository/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

// ผู้ใช้ที่ login อยู่ — สร้างครั้งเดียวที่ shell ใช้ทั้งเมนูข้าง (ชื่อ / รูป) และหน้าโปรไฟล์
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this.repository) : super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileSaved>(_onSaved);
    on<PasswordChanged>(_onPasswordChanged);
    on<AvatarUploaded>(_onAvatarUploaded);
    on<AvatarRemoved>(_onAvatarRemoved);
  }

  final UserRepository repository;

  Future<void> _onRequested(ProfileRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final user = await repository.getMe();
      emit(state.copyWith(status: AppStatus.success, user: user));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onSaved(ProfileSaved event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      final user = await repository.updateProfile(firstName: event.firstName, lastName: event.lastName);
      emit(state.copyWith(saveStatus: AppStatus.success, user: user));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onPasswordChanged(PasswordChanged event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(passwordStatus: AppStatus.loading));
    try {
      await repository.changePassword(currentPassword: event.currentPassword, newPassword: event.newPassword);
      emit(state.copyWith(passwordStatus: AppStatus.success));
    } catch (error) {
      emit(state.copyWith(passwordStatus: AppStatus.failure, passwordErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onAvatarUploaded(AvatarUploaded event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(avatarStatus: AppStatus.loading));
    try {
      final user = await repository.uploadAvatar(event.bytes);
      emit(state.copyWith(avatarStatus: AppStatus.success, user: user));
    } catch (error) {
      emit(state.copyWith(avatarStatus: AppStatus.failure, avatarErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onAvatarRemoved(AvatarRemoved event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(avatarStatus: AppStatus.loading));
    try {
      final user = await repository.deleteAvatar();
      emit(state.copyWith(avatarStatus: AppStatus.success, user: user));
    } catch (error) {
      emit(state.copyWith(avatarStatus: AppStatus.failure, avatarErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}

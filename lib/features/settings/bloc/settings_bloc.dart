import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/form_layout_util.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this.repository) : super(const SettingsState()) {
    on<SettingsRequested>(_onSettingsRequested);
    on<CompanySaved>(_onCompanySaved);
    on<LogoUploaded>(_onLogoUploaded);
    on<LogoRemoved>(_onLogoRemoved);
    on<ProductFieldSaved>(_onFieldSaved);
    on<ProductFieldDeleted>(_onFieldDeleted);
    on<ProductFormLayoutSaved>(_onLayoutSaved);
  }

  final SettingsRepository repository;

  Future<void> _onSettingsRequested(SettingsRequested event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final company = await repository.getCompany();
      final fields = await repository.getFields();
      final formLayout = await _formLayoutOrDefault();
      emit(state.copyWith(status: AppStatus.success, company: company, fields: fields, formLayout: formLayout));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  // โหลดลำดับฟอร์มไม่ได้ (เช่น API ยังไม่ได้อัปเดต) → ใช้ลำดับเริ่มต้น หน้าตั้งค่ายังใช้ได้
  Future<List<String>> _formLayoutOrDefault() async {
    try {
      return await repository.getFormLayout();
    } catch (_) {
      return const [];
    }
  }

  // ย้ายแล้วโชว์ลำดับใหม่ทันที แล้วค่อยบันทึก / บันทึกไม่ได้ → กลับไปลำดับเดิม
  // ลากหลายครั้งติดกัน: ผลของครั้งเก่าที่กลับมาทีหลังไม่ทับลำดับล่าสุด
  Future<void> _onLayoutSaved(ProductFormLayoutSaved event, Emitter<SettingsState> emit) async {
    final before = state.formLayout;
    emit(state.copyWith(formLayout: event.keys, layoutStatus: AppStatus.loading, layoutErrorCode: ''));
    try {
      final saved = await repository.saveFormLayout(event.keys);
      if (!identical(state.formLayout, event.keys)) return;
      emit(state.copyWith(formLayout: saved, layoutStatus: AppStatus.success));
    } catch (error) {
      if (!identical(state.formLayout, event.keys)) return;
      emit(
        state.copyWith(formLayout: before, layoutStatus: AppStatus.failure, layoutErrorCode: ErrorUtil.codeOf(error)),
      );
    }
  }

  Future<void> _onCompanySaved(CompanySaved event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      final company = await repository.updateCompany(event.company);
      emit(state.copyWith(saveStatus: AppStatus.success, company: company));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onLogoUploaded(LogoUploaded event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(logoStatus: AppStatus.loading));
    try {
      final company = await repository.uploadLogo(event.bytes);
      emit(state.copyWith(logoStatus: AppStatus.success, company: company));
    } catch (error) {
      emit(state.copyWith(logoStatus: AppStatus.failure, logoErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onLogoRemoved(LogoRemoved event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(logoStatus: AppStatus.loading));
    try {
      await repository.deleteLogo();
      final company = await repository.getCompany();
      emit(state.copyWith(logoStatus: AppStatus.success, company: company));
    } catch (error) {
      emit(state.copyWith(logoStatus: AppStatus.failure, logoErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onFieldSaved(ProductFieldSaved event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(fieldStatus: AppStatus.loading));
    try {
      await repository.saveField(event.field);
      final fields = await repository.getFields();
      emit(state.copyWith(fieldStatus: AppStatus.success, fields: fields));
    } catch (error) {
      emit(state.copyWith(fieldStatus: AppStatus.failure, fieldErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onFieldDeleted(ProductFieldDeleted event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(fieldStatus: AppStatus.loading));
    try {
      await repository.deleteField(event.id);
      final fields = state.fields.where((field) => field.id != event.id).toList();
      emit(state.copyWith(fieldStatus: AppStatus.success, fields: fields));
    } catch (error) {
      emit(state.copyWith(fieldStatus: AppStatus.failure, fieldErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}

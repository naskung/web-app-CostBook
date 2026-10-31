import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this.repository) : super(const SettingsState()) {
    on<SettingsRequested>(_onSettingsRequested);
    on<CompanySaved>(_onCompanySaved);
    on<ProductFieldSaved>(_onFieldSaved);
    on<ProductFieldDeleted>(_onFieldDeleted);
  }

  final SettingsRepository repository;

  Future<void> _onSettingsRequested(SettingsRequested event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final company = await repository.getCompany();
      final fields = await repository.getFields();
      emit(state.copyWith(status: AppStatus.success, company: company, fields: fields));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
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

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository repository;
  const company = CompanyModel(name: 'ร้านตัวอย่าง', taxId: '0105555555555');

  setUpAll(() {
    registerFallbackValue(const CompanyModel());
  });

  setUp(() {
    repository = MockSettingsRepository();
  });

  blocTest<SettingsBloc, SettingsState>(
    'SettingsRequested สำเร็จ ได้ loading แล้ว success พร้อมข้อมูลร้าน',
    build: () {
      when(() => repository.getCompany()).thenAnswer((_) async => company);
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(SettingsRequested()),
    expect: () => [
      const SettingsState(status: AppStatus.loading),
      const SettingsState(status: AppStatus.success, company: company),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'SettingsRequested ต่อ server ไม่ได้ ได้ failure พร้อม code network_error',
    build: () {
      when(() => repository.getCompany()).thenThrow(ApiException('network_error'));
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(SettingsRequested()),
    expect: () => [
      const SettingsState(status: AppStatus.loading),
      const SettingsState(status: AppStatus.failure, errorCode: 'network_error'),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'CompanySaved สำเร็จ ได้ saveStatus success และข้อมูลร้านใหม่',
    build: () {
      when(() => repository.updateCompany(any())).thenAnswer((_) async => company);
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(CompanySaved(company)),
    expect: () => [
      const SettingsState(saveStatus: AppStatus.loading),
      const SettingsState(saveStatus: AppStatus.success, company: company),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'CompanySaved เลขภาษีผิด ได้ saveStatus failure พร้อม code จาก API',
    build: () {
      when(() => repository.updateCompany(any())).thenThrow(ApiException('company_tax_id_invalid'));
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(CompanySaved(company)),
    expect: () => [
      const SettingsState(saveStatus: AppStatus.loading),
      const SettingsState(saveStatus: AppStatus.failure, saveErrorCode: 'company_tax_id_invalid'),
    ],
  );
}

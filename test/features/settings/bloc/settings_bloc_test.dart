import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository repository;
  const company = CompanyModel(name: 'ร้านตัวอย่าง', taxId: '0105555555555');
  const material = ProductFieldModel(id: 'f1', name: 'วัสดุ', type: 'select', options: ['PLA'], showInList: true);
  const color = ProductFieldModel(id: 'f2', name: 'สี', type: 'text');

  setUpAll(() {
    registerFallbackValue(const CompanyModel());
    registerFallbackValue(material);
  });

  setUp(() {
    repository = MockSettingsRepository();
  });

  blocTest<SettingsBloc, SettingsState>(
    'SettingsRequested สำเร็จ ได้ loading แล้ว success พร้อมข้อมูลร้าน',
    build: () {
      when(() => repository.getCompany()).thenAnswer((_) async => company);
      when(() => repository.getFields()).thenAnswer((_) async => [material, color]);
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(SettingsRequested()),
    expect:
        () => [
          const SettingsState(status: AppStatus.loading),
          const SettingsState(status: AppStatus.success, company: company, fields: [material, color]),
        ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'SettingsRequested ต่อ server ไม่ได้ ได้ failure พร้อม code network_error',
    build: () {
      when(() => repository.getCompany()).thenThrow(ApiException('network_error'));
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(SettingsRequested()),
    expect:
        () => [
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
    expect:
        () => [
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
    expect:
        () => [
          const SettingsState(saveStatus: AppStatus.loading),
          const SettingsState(saveStatus: AppStatus.failure, saveErrorCode: 'company_tax_id_invalid'),
        ],
  );

  test('listFields เหลือเฉพาะช่องที่ตั้งให้โชว์ในตาราง', () {
    const state = SettingsState(fields: [material, color]);
    expect(state.listFields, [material]);
  });

  blocTest<SettingsBloc, SettingsState>(
    'ProductFieldSaved สำเร็จ บันทึกแล้วโหลดรายการช่องใหม่',
    build: () {
      when(() => repository.saveField(any())).thenAnswer((_) async {});
      when(() => repository.getFields()).thenAnswer((_) async => [material]);
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(ProductFieldSaved(material)),
    expect:
        () => [
          const SettingsState(fieldStatus: AppStatus.loading),
          const SettingsState(fieldStatus: AppStatus.success, fields: [material]),
        ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'ProductFieldSaved แบบตัวเลือกแต่ไม่ใส่ตัวเลือก ได้ fieldStatus failure พร้อม code',
    build: () {
      when(() => repository.saveField(any())).thenThrow(ApiException('field_options_required'));
      return SettingsBloc(repository);
    },
    act: (bloc) => bloc.add(ProductFieldSaved(material)),
    expect:
        () => [
          const SettingsState(fieldStatus: AppStatus.loading),
          const SettingsState(fieldStatus: AppStatus.failure, fieldErrorCode: 'field_options_required'),
        ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'ProductFieldDeleted สำเร็จ ช่องหายจากรายการ',
    build: () {
      when(() => repository.deleteField('f2')).thenAnswer((_) async {});
      return SettingsBloc(repository);
    },
    seed: () => const SettingsState(fields: [material, color]),
    act: (bloc) => bloc.add(ProductFieldDeleted('f2')),
    expect:
        () => [
          const SettingsState(fields: [material, color], fieldStatus: AppStatus.loading),
          const SettingsState(fields: [material], fieldStatus: AppStatus.success),
        ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'ProductFieldDeleted ไม่เจอช่อง ได้ fieldStatus failure และช่องยังอยู่',
    build: () {
      when(() => repository.deleteField('f2')).thenThrow(ApiException('field_not_found'));
      return SettingsBloc(repository);
    },
    seed: () => const SettingsState(fields: [material, color]),
    act: (bloc) => bloc.add(ProductFieldDeleted('f2')),
    expect:
        () => [
          const SettingsState(fields: [material, color], fieldStatus: AppStatus.loading),
          const SettingsState(
            fields: [material, color],
            fieldStatus: AppStatus.failure,
            fieldErrorCode: 'field_not_found',
          ),
        ],
  );
}

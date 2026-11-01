import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/widgets/logo_section.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

void main() {
  late MockSettingsBloc bloc;

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    bloc = MockSettingsBloc();
  });

  Future<void> pumpSection(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<SettingsBloc>.value(value: bloc, child: const SingleChildScrollView(child: LogoSection())),
        ),
      ),
    );
  }

  testWidgets('ยังไม่มีโลโก้ → มีปุ่ม เลือกโลโก้ ไม่มีปุ่มลบ', (tester) async {
    when(() => bloc.state).thenReturn(const SettingsState(company: CompanyModel(name: 'ร้าน')));
    await pumpSection(tester);
    expect(find.text('settings.logo_pick'.tr), findsOneWidget);
    expect(find.text('settings.logo_remove'.tr), findsNothing);
  });

  testWidgets('มีโลโก้แล้ว → มีปุ่ม เปลี่ยนโลโก้ และ ลบโลโก้', (tester) async {
    when(() => bloc.state).thenReturn(const SettingsState(company: CompanyModel(name: 'ร้าน', hasLogo: true)));
    await pumpSection(tester);
    expect(find.text('settings.logo_change'.tr), findsOneWidget);
    expect(find.text('settings.logo_remove'.tr), findsOneWidget);
  });

  testWidgets('กำลังอัปโหลด → กดปุ่มไม่ได้', (tester) async {
    when(() => bloc.state).thenReturn(
      const SettingsState(company: CompanyModel(name: 'ร้าน', hasLogo: true), logoStatus: AppStatus.loading),
    );
    await pumpSection(tester);
    final change = tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text('settings.logo_change'.tr), matching: find.bySubtype<ButtonStyleButton>()),
    );
    final remove = tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text('settings.logo_remove'.tr), matching: find.bySubtype<ButtonStyleButton>()),
    );
    expect([change.enabled, remove.enabled], [false, false]);
  });

  void whenLogoFinished(SettingsState result) {
    const loading = SettingsState(logoStatus: AppStatus.loading);
    whenListen(bloc, Stream.value(result), initialState: loading);
  }

  testWidgets('อัปโหลด / ลบโลโก้สำเร็จ → แจ้ง อัปเดตโลโก้แล้ว', (tester) async {
    whenLogoFinished(const SettingsState(logoStatus: AppStatus.success));
    await pumpSection(tester);
    await tester.pump();
    expect(find.text('settings.logo_saved'.tr), findsOneWidget);
  });

  testWidgets('อัปโหลดไม่สำเร็จ → แจ้ง error จาก API', (tester) async {
    whenLogoFinished(const SettingsState(logoStatus: AppStatus.failure, logoErrorCode: 'logo_type_invalid'));
    await pumpSection(tester);
    await tester.pump();
    expect(find.text('error.logo_type_invalid'.tr), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/pages/profile_page.dart';
import 'package:costbook/features/user/repository/user_repository.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserRepository repository;

  const owner = UserModel(id: 'u1', email: 'owner@b.co', firstName: 'สมชาย', lastName: 'ใจดี', role: UserRole.owner);
  const staff = UserModel(id: 'u2', email: 'staff@b.co', firstName: 'สมศรี', role: UserRole.staff);

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() => repository = MockUserRepository());

  Future<void> pumpPage(WidgetTester tester, UserModel user, {Size size = const Size(1280, 1800)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => repository.getMe()).thenAnswer((_) async => user);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BlocProvider(
            create: (_) => ProfileBloc(repository)..add(ProfileRequested()),
            child: const ProfilePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String labelKey) {
    return find.descendant(of: find.widgetWithText(AppTextField, labelKey.tr), matching: find.byType(TextFormField));
  }

  testWidgets('แสดงชื่อ อีเมล ตำแหน่ง และตัวอักษรย่อแทนรูป / เจ้าของร้านมีปุ่มจัดการผู้ใช้', (tester) async {
    await pumpPage(tester, owner);
    expect(find.text('สมชาย ใจดี'), findsOneWidget);
    expect(find.text('owner@b.co'), findsWidgets);
    expect(find.text('role.owner'.tr), findsOneWidget);
    expect(find.text('ส'), findsOneWidget);
    expect(find.text('profile.manage_users'.tr), findsOneWidget);
  });

  testWidgets('พนักงาน ไม่เห็นปุ่มจัดการผู้ใช้', (tester) async {
    await pumpPage(tester, staff);
    expect(find.text('role.staff'.tr), findsOneWidget);
    expect(find.text('profile.manage_users'.tr), findsNothing);
  });

  testWidgets('แก้ชื่อแล้วบันทึก ส่งชื่อใหม่ไป API และชื่อบนการ์ดเปลี่ยนตาม', (tester) async {
    when(
      () => repository.updateProfile(firstName: 'สมหญิง', lastName: 'ใจดี'),
    ).thenAnswer((_) async => const UserModel(id: 'u1', firstName: 'สมหญิง', lastName: 'ใจดี', role: UserRole.owner));
    await pumpPage(tester, owner);
    await tester.enterText(field('profile.first_name'), 'สมหญิง');
    await tester.tap(find.text('common.save'.tr));
    await tester.pumpAndSettle();
    verify(() => repository.updateProfile(firstName: 'สมหญิง', lastName: 'ใจดี')).called(1);
    expect(find.text('สมหญิง ใจดี'), findsOneWidget);
  });

  testWidgets('ยืนยันรหัสผ่านไม่ตรง ขึ้นข้อความเตือน ไม่ส่งไป API', (tester) async {
    await pumpPage(tester, owner);
    await tester.enterText(field('profile.current_password'), 'old123');
    await tester.enterText(field('profile.new_password'), 'new123');
    await tester.enterText(field('profile.confirm_password'), 'new124');
    await tester.tap(find.widgetWithText(ElevatedButton, 'profile.change_password'.tr));
    await tester.pumpAndSettle();
    expect(find.text('validation.password_mismatch'.tr), findsOneWidget);
    verifyNever(
      () => repository.changePassword(
        currentPassword: any(named: 'currentPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('เปลี่ยนรหัสผ่านสำเร็จ ล้างช่องให้ / รหัสเดิมผิด ขึ้นข้อความจาก API', (tester) async {
    when(() => repository.changePassword(currentPassword: 'old123', newPassword: 'new123')).thenAnswer((_) async {});
    when(
      () => repository.changePassword(currentPassword: 'wrong1', newPassword: 'new123'),
    ).thenThrow(ApiException('password_current_invalid'));
    await pumpPage(tester, owner);

    Future<void> changePassword(String current) async {
      await tester.enterText(field('profile.current_password'), current);
      await tester.enterText(field('profile.new_password'), 'new123');
      await tester.enterText(field('profile.confirm_password'), 'new123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'profile.change_password'.tr));
      await tester.pumpAndSettle();
    }

    await changePassword('wrong1');
    expect(find.text('error.password_current_invalid'.tr), findsOneWidget);

    await changePassword('old123');
    expect(find.text('profile.password_changed'.tr), findsOneWidget);
    final currentField = tester.widget<TextFormField>(field('profile.current_password'));
    expect(currentField.controller?.text, '');
  });

  testWidgets('มือถือ 375 แสดงหน้าได้ไม่ล้นจอ', (tester) async {
    await pumpPage(tester, owner, size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });
}

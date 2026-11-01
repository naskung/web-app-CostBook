import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/bloc/user_list_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/pages/user_list_page.dart';
import 'package:costbook/features/user/repository/user_repository.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserRepository repository;

  const owner = UserModel(id: 'u1', email: 'owner@b.co', firstName: 'สมชาย', role: UserRole.owner);
  const staff = UserModel(id: 'u2', email: 'staff@b.co', firstName: 'สมศรี', role: UserRole.staff, isActive: false);

  setUpAll(() async {
    await AppLang.load('th');
    registerFallbackValue(const UserModel());
  });

  setUp(() {
    repository = MockUserRepository();
    when(() => repository.getMe()).thenAnswer((_) async => owner);
    when(() => repository.getUsers()).thenAnswer((_) async => [owner, staff]);
  });

  Future<void> pumpPage(WidgetTester tester, {Size size = const Size(1280, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ProfileBloc(repository)..add(ProfileRequested())),
              BlocProvider(create: (_) => UserListBloc(repository)..add(UsersRequested())),
            ],
            child: const UserListPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder dialogField(String labelKey) {
    final appTextField = find.descendant(
      of: find.byType(Dialog),
      matching: find.widgetWithText(AppTextField, labelKey.tr),
    );
    return find.descendant(of: appTextField, matching: find.byType(TextFormField));
  }

  testWidgets('แสดงผู้ใช้ทุกคน พร้อมตำแหน่ง สถานะ และบอกว่าแถวไหนคือตัวเอง', (tester) async {
    await pumpPage(tester);
    expect(find.text('user.you'.trParams({'name': 'สมชาย'})), findsOneWidget);
    expect(find.text('สมศรี'), findsOneWidget);
    expect(find.text('role.owner'.tr), findsOneWidget);
    expect(find.text('role.staff'.tr), findsOneWidget);
    expect(find.text('user.active'.tr), findsOneWidget);
    expect(find.text('user.inactive'.tr), findsOneWidget);
  });

  testWidgets('ไม่ใช่เจ้าของร้าน (API ตอบ forbidden) ขึ้นข้อความไม่มีสิทธิ์ ไม่มีปุ่มเพิ่มผู้ใช้ / ปุ่มลองใหม่', (
    tester,
  ) async {
    when(() => repository.getUsers()).thenThrow(ApiException('forbidden'));
    await pumpPage(tester);
    expect(find.text('error.forbidden'.tr), findsOneWidget);
    expect(find.text('user.add'.tr), findsNothing);
    expect(find.text('common.retry'.tr), findsNothing);
  });

  testWidgets('เพิ่มผู้ใช้ กรอกครบแล้วบันทึก ส่งอีเมล ชื่อ ตำแหน่ง และรหัสแรกไป API', (tester) async {
    when(() => repository.createUser(any(), any())).thenAnswer((_) async {});
    await pumpPage(tester);
    await tester.tap(find.text('user.add'.tr));
    await tester.pumpAndSettle();
    await tester.enterText(dialogField('profile.email'), 'new@b.co');
    await tester.enterText(dialogField('profile.first_name'), 'มานี');
    await tester.enterText(dialogField('user.first_password'), '123456');
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('common.save'.tr)));
    await tester.pumpAndSettle();

    final captured = verify(() => repository.createUser(captureAny(), '123456')).captured.single as UserModel;
    expect(captured.email, 'new@b.co');
    expect(captured.firstName, 'มานี');
    expect(captured.role, UserRole.staff);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('เพิ่มผู้ใช้ รหัสแรกสั้นเกิน ขึ้นข้อความเตือน ไม่ส่งไป API', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('user.add'.tr));
    await tester.pumpAndSettle();
    await tester.enterText(dialogField('profile.email'), 'new@b.co');
    await tester.enterText(dialogField('profile.first_name'), 'มานี');
    await tester.enterText(dialogField('user.first_password'), '123');
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('common.save'.tr)));
    await tester.pumpAndSettle();
    expect(find.text('validation.password_too_short'.trParams({'min': '6'})), findsOneWidget);
    verifyNever(() => repository.createUser(any(), any()));
  });

  testWidgets('แก้บัญชีตัวเอง เปลี่ยนตำแหน่ง / ปิดบัญชีไม่ได้ และมีข้อความบอก', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('user.you'.trParams({'name': 'สมชาย'})));
    await tester.pumpAndSettle();
    expect(find.text('user.self_hint'.tr), findsOneWidget);
    final activeSwitch = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(activeSwitch.onChanged, isNull);
  });

  testWidgets('แก้ผู้ใช้อื่น เปิดบัญชีที่ปิดอยู่ ส่ง active = true ไป API', (tester) async {
    when(() => repository.updateUser(any())).thenAnswer((_) async {});
    await pumpPage(tester);
    await tester.tap(find.text('สมศรี'));
    await tester.pumpAndSettle();
    expect(find.text('user.self_hint'.tr), findsNothing);
    await tester.tap(find.byType(SwitchListTile));
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('common.save'.tr)));
    await tester.pumpAndSettle();
    final captured = verify(() => repository.updateUser(captureAny())).captured.single as UserModel;
    expect(captured.id, 'u2');
    expect(captured.isActive, true);
  });

  testWidgets('ตั้งรหัสผ่านใหม่ให้ผู้ใช้ ส่งรหัสใหม่ไป API แล้วขึ้นข้อความสำเร็จ', (tester) async {
    when(() => repository.resetPassword('u2', 'abcdef')).thenAnswer((_) async {});
    await pumpPage(tester);
    await tester.tap(find.byTooltip('user.reset_password'.tr).last);
    await tester.pumpAndSettle();
    await tester.enterText(dialogField('profile.new_password'), 'abcdef');
    await tester.enterText(dialogField('profile.confirm_password'), 'abcdef');
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('common.save'.tr)));
    await tester.pumpAndSettle();
    verify(() => repository.resetPassword('u2', 'abcdef')).called(1);
    expect(find.text('user.reset_password_done'.tr), findsOneWidget);
  });

  testWidgets('มือถือ 375 แสดงเป็นการ์ดได้ไม่ล้นจอ', (tester) async {
    await pumpPage(tester, size: const Size(375, 800));
    expect(tester.takeException(), isNull);
    expect(find.text('สมศรี'), findsOneWidget);
  });
}

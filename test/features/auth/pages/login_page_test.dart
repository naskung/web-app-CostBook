import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/pages/login_page.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/organisms/screen_scaler.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository repository;

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    repository = MockAuthRepository();
  });

  void whenLogin(Future<void> Function() answer) {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        rememberMe: any(named: 'rememberMe'),
      ),
    ).thenAnswer((_) => answer());
  }

  Future<void> pumpLoginPage(WidgetTester tester, Size screenSize) async {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => BlocProvider(
            create: (_) => AuthBloc(repository),
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const Text('dashboard-page'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()),
        routerConfig: router,
      ),
    );
  }

  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).first, '  admin@costbook.com  ');
    await tester.enterText(find.byType(TextFormField).last, '1234');
  }

  Future<void> tapLoginButton(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
  }

  final screenSizes = {
    'มือถือเล็ก 320x568': const Size(320, 568),
    'มือถือ 375x667': const Size(375, 667),
    'แท็บเล็ต 768x1024': const Size(768, 1024),
    'จอคอมแนวตั้ง 1072x1782': const Size(1072, 1782),
    'โน้ตบุ๊ก 1280x720': const Size(1280, 720),
    'จอคอม 1920x1080': const Size(1920, 1080),
    'จอใหญ่ 2560x1440': const Size(2560, 1440),
  };

  screenSizes.forEach((name, size) {
    testWidgets('$name แสดงชื่อแอปและฟอร์ม login ได้ไม่ล้นจอ', (tester) async {
      await pumpLoginPage(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('app.name'.tr), findsOneWidget);
      expect(find.text('login.subtitle'.tr), findsOneWidget);
    });
  });

  testWidgets('แสดงชื่อช่องอีเมลและรหัสผ่านไว้เหนือช่องกรอก', (tester) async {
    await pumpLoginPage(tester, const Size(375, 667));
    expect(find.text('login.email'.tr), findsOneWidget);
    expect(find.text('login.password'.tr), findsOneWidget);
  });

  testWidgets('จดจำการเข้าสู่ระบบ เริ่มต้นไม่ติ๊ก', (tester) async {
    await pumpLoginPage(tester, const Size(375, 667));
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, false);
  });

  testWidgets('กดจดจำการเข้าสู่ระบบ แล้วติ๊กถูก', (tester) async {
    await pumpLoginPage(tester, const Size(375, 667));
    await tester.ensureVisible(find.text('login.remember_me'.tr));
    await tester.tap(find.text('login.remember_me'.tr));
    await tester.pump();
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, true);
  });

  testWidgets('กดเข้าสู่ระบบโดยไม่กรอก แสดงข้อความให้กรอกทั้ง 2 ช่อง', (tester) async {
    await pumpLoginPage(tester, const Size(375, 667));
    await tapLoginButton(tester);
    expect(find.text('validation.required'.tr), findsNWidgets(2));
  });

  testWidgets('อีเมลผิดรูปแบบ แสดงข้อความอีเมลไม่ถูกต้อง', (tester) async {
    await pumpLoginPage(tester, const Size(375, 667));
    await tester.enterText(find.byType(TextFormField).first, 'abc');
    await tapLoginButton(tester);
    expect(find.text('validation.email_invalid'.tr), findsOneWidget);
  });

  testWidgets('กดรูปตา แสดงรหัสผ่านที่ซ่อนอยู่', (tester) async {
    await pumpLoginPage(tester, const Size(375, 667));
    await tester.ensureVisible(find.byIcon(Icons.visibility_outlined));
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('กรอกครบแล้วกดเข้าสู่ระบบ ส่งอีเมล (ตัดช่องว่าง) รหัสผ่าน และค่าจดจำ ไปที่ repository', (tester) async {
    whenLogin(() async {});
    await pumpLoginPage(tester, const Size(375, 667));
    await fillForm(tester);
    await tester.ensureVisible(find.text('login.remember_me'.tr));
    await tester.tap(find.text('login.remember_me'.tr));
    await tapLoginButton(tester);
    verify(() => repository.login(email: 'admin@costbook.com', password: '1234', rememberMe: true)).called(1);
  });

  testWidgets('กรอกไม่ครบ ไม่เรียก repository', (tester) async {
    whenLogin(() async {});
    await pumpLoginPage(tester, const Size(375, 667));
    await tapLoginButton(tester);
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        rememberMe: any(named: 'rememberMe'),
      ),
    );
  });

  testWidgets('กำลัง login ปุ่มแสดงวงกลมหมุน และกดซ้ำไม่ได้', (tester) async {
    final loginResult = Completer<void>();
    whenLogin(() => loginResult.future);
    await pumpLoginPage(tester, const Size(375, 667));
    await fillForm(tester);
    await tapLoginButton(tester);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    loginResult.complete();
    await tester.pump();
  });

  testWidgets('รหัสผ่านผิด แสดงข้อความ อีเมลหรือรหัสผ่านไม่ถูกต้อง', (tester) async {
    whenLogin(() async => throw ApiException('invalid_credentials'));
    await pumpLoginPage(tester, const Size(375, 667));
    await fillForm(tester);
    await tapLoginButton(tester);
    await tester.pump();
    expect(find.text('error.invalid_credentials'.tr), findsOneWidget);
  });

  testWidgets('ต่อ server ไม่ได้ แสดงข้อความเชื่อมต่อไม่ได้', (tester) async {
    whenLogin(() async => throw ApiException('network_error'));
    await pumpLoginPage(tester, const Size(375, 667));
    await fillForm(tester);
    await tapLoginButton(tester);
    await tester.pump();
    expect(find.text('error.network_error'.tr), findsOneWidget);
  });

  testWidgets('login สำเร็จ ไปหน้าแรก', (tester) async {
    whenLogin(() async {});
    await pumpLoginPage(tester, const Size(375, 667));
    await fillForm(tester);
    await tapLoginButton(tester);
    await tester.pumpAndSettle();
    expect(find.text('dashboard-page'), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}

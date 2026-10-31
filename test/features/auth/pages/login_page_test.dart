import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/auth/pages/login_page.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/organisms/screen_scaler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLang.load('th');
  });

  Future<void> pumpLoginPage(WidgetTester tester, Size screenSize) async {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()),
        home: const LoginPage(),
      ),
    );
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
}

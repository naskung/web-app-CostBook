import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLang.load('th');
  });

  testWidgets('แสดงข้อความต้อนรับ และบอกว่าหน้านี้จะแสดงอะไร', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const Scaffold(body: DashboardPage())),
    );
    expect(find.text('dashboard.welcome'.tr), findsOneWidget);
    expect(find.text('dashboard.description'.tr), findsOneWidget);
  });
}

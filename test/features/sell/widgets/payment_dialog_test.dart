import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/sell/widgets/payment_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLang.load('th');
  });

  late double? result;

  Future<void> openDialog(WidgetTester tester, double total) async {
    result = -1;
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed: () async => result = await PaymentDialog.show(context, total),
                  child: const Text('open'),
                ),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder confirmButton() => find.widgetWithText(ElevatedButton, 'sell.confirm_pay'.tr);

  testWidgets('กดปุ่มลัด 500 เห็นเงินทอน แล้วยืนยัน ได้เงินที่รับมา', (tester) async {
    await openDialog(tester, 349.52);
    await tester.tap(find.text('500'));
    await tester.pump();
    expect(find.text('150.48'), findsOneWidget);
    await tester.tap(confirmButton());
    await tester.pumpAndSettle();
    expect(result, 500);
  });

  testWidgets('ไม่ใส่เงินที่รับมา = จ่ายพอดี (เงินทอน 0)', (tester) async {
    await openDialog(tester, 349.52);
    expect(find.text('0.00'), findsOneWidget);
    await tester.tap(confirmButton());
    await tester.pumpAndSettle();
    expect(result, 349.52);
  });

  testWidgets('เงินไม่พอ บอกว่าขาดเท่าไหร่ และกดยืนยันไม่ได้', (tester) async {
    await openDialog(tester, 349.52);
    await tester.enterText(find.byType(TextField), '300');
    await tester.pump();
    expect(find.text('sell.not_enough'.trParams({'amount': '49.52'})), findsOneWidget);
    expect(tester.widget<ElevatedButton>(confirmButton()).onPressed, isNull);
  });

  testWidgets('กดยกเลิก ได้ null (ไม่ขาย)', (tester) async {
    await openDialog(tester, 100);
    await tester.tap(find.widgetWithText(OutlinedButton, 'common.cancel'.tr));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}

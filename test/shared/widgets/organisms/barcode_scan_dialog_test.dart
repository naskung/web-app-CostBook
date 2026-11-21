import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/organisms/barcode_scan_button.dart';
import 'package:costbook/shared/widgets/organisms/barcode_scan_dialog.dart';

void main() {
  setUpAll(() async {
    await AppLang.load('th');
  });

  testWidgets('กดปุ่มสแกน เปิดหน้าต่างกล้อง / กดปิดโดยยังไม่ได้สแกน ไม่ส่งรหัสอะไรกลับ', (tester) async {
    final scanned = <String>[];
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: Scaffold(body: BarcodeScanButton(onScanned: scanned.add))),
    );

    await tester.tap(find.byTooltip('barcode.scan'.tr));
    await tester.pumpAndSettle();
    expect(find.byType(BarcodeScanDialog), findsOneWidget);
    expect(find.text('barcode.title'.tr), findsOneWidget);
    expect(find.text('barcode.subtitle'.tr), findsOneWidget);

    await tester.tap(find.byTooltip('common.close'.tr));
    await tester.pumpAndSettle();
    expect(find.byType(BarcodeScanDialog), findsNothing);
    expect(scanned, isEmpty);
  });
}

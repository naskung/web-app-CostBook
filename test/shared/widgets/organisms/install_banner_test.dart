import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/organisms/install_banner.dart';

void main() {
  setUpAll(() async {
    await AppLang.load('th');
  });

  for (final width in [320.0, 375.0, 1280.0]) {
    testWidgets('กว้าง $width: กดเพิ่มไว้ที่หน้าจอ / กดปิด (ไม่ต้องแนะนำอีก) เรียกคนละอย่าง ไม่ล้นจอ', (tester) async {
      var added = 0;
      var dismissed = 0;
      tester.view.physicalSize = Size(width, 200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: InstallBanner(onAdd: () => added++, onDismiss: () => dismissed++)),
        ),
      );

      expect(find.text('install.banner'.tr), findsOneWidget);
      await tester.tap(find.text('install.add'.tr));
      await tester.tap(find.byTooltip('install.dismiss'.tr));
      expect([added, dismissed], [1, 1]);
      expect(tester.takeException(), isNull);
    });
  }
}

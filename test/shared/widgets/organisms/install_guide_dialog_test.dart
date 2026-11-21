import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/install_guide.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/organisms/install_guide_dialog.dart';

void main() {
  setUpAll(() async {
    await AppLang.load('th');
  });

  Future<void> pumpDialog(WidgetTester tester, InstallGuide guide) {
    tester.view.physicalSize = const Size(375, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: Scaffold(body: InstallGuideDialog(guide: guide))),
    );
  }

  testWidgets('iPhone: โชว์วิธีของเครื่องนี้ก่อน วิธีเครื่องอื่นซ่อนไว้จนกดเปิด', (tester) async {
    await pumpDialog(tester, InstallGuide.iphone);
    expect(find.text(InstallGuide.iphone.stepsKey.tr), findsOneWidget);
    expect(find.text(InstallGuide.android.stepsKey.tr), findsNothing);

    await tester.tap(find.text('install.other_devices'.tr));
    await tester.pumpAndSettle();
    for (final other in [
      InstallGuide.android,
      InstallGuide.desktop,
      InstallGuide.macSafari,
      InstallGuide.firefoxDesktop,
    ]) {
      expect(find.text(other.titleKey.tr), findsOneWidget);
    }
    expect(find.text(InstallGuide.iphone.titleKey.tr), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Firefox บนคอม: บอกว่าเพิ่มเป็นแอปไม่ได้ ให้เปิดใน Chrome / Edge', (tester) async {
    await pumpDialog(tester, InstallGuide.firefoxDesktop);
    expect(find.text(InstallGuide.firefoxDesktop.stepsKey.tr), findsOneWidget);
  });
}

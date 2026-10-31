import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/shared/widgets/organisms/screen_scaler.dart';

void main() {
  Future<double> innerWidthOnScreen(WidgetTester tester, double screenWidth) async {
    tester.view.physicalSize = Size(screenWidth, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var innerWidth = 0.0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()),
        home: Builder(
          builder: (context) {
            innerWidth = MediaQuery.sizeOf(context).width;
            return const SizedBox();
          },
        ),
      ),
    );
    return innerWidth;
  }

  testWidgets('จอกว้าง 1280 แสดงตามปกติ หน้าจอเห็นกว้าง 1280', (tester) async {
    expect(await innerWidthOnScreen(tester, 1280), 1280);
  });

  testWidgets('จอกว้าง 2880 ขยาย 2 เท่า หน้าจอเห็นกว้าง 1440 เท่าที่ออกแบบ', (tester) async {
    expect(await innerWidthOnScreen(tester, 2880), 1440);
  });

  testWidgets('จอกว้าง 5760 ขยายแค่ 2 เท่า หน้าจอเห็นกว้าง 2880', (tester) async {
    expect(await innerWidthOnScreen(tester, 5760), 2880);
  });

  testWidgets('จอกว้าง 2880 ปุ่มกดได้ปกติหลังขยาย', (tester) async {
    tester.view.physicalSize = const Size(2880, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()),
        home: Scaffold(
          body: Center(
            child: ElevatedButton(onPressed: () => tapped = true, child: const Text('ok')),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, true);
  });
}

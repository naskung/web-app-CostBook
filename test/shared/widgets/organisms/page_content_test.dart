import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/shared/widgets/organisms/page_content.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, {Widget? centerChild}) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageContent(
            centerChild: centerChild,
            children: const [SizedBox(height: 100, child: Text('toolbar'))],
          ),
        ),
      ),
    );
  }

  testWidgets('ของที่อยู่ใน children เรียงจากด้านบน', (tester) async {
    await pumpPage(tester);
    expect(tester.getTopLeft(find.text('toolbar')).dy, lessThan(100));
  });

  testWidgets('centerChild อยู่กึ่งกลางของพื้นที่ที่เหลือใต้ children', (tester) async {
    await pumpPage(tester, centerChild: const Text('ยังไม่มีสินค้า'));
    final toolbarBottom = tester.getBottomLeft(find.byType(SizedBox).first).dy;
    final emptyCenter = tester.getCenter(find.text('ยังไม่มีสินค้า')).dy;
    final remainingCenter = (toolbarBottom + 800) / 2;
    expect(emptyCenter, closeTo(remainingCenter, 30));
  });

  testWidgets('centerChild อยู่กึ่งกลางแนวนอน', (tester) async {
    await pumpPage(tester, centerChild: const Text('ยังไม่มีสินค้า'));
    expect(tester.getCenter(find.text('ยังไม่มีสินค้า')).dx, closeTo(640, 1));
  });
}

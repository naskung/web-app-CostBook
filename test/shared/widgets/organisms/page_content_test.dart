import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';

void main() {
  setUpAll(() async {
    await AppLang.load('th');
  });

  Future<void> pumpPage(WidgetTester tester, {Widget? centerChild}) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageContent(centerChild: centerChild, children: const [SizedBox(height: 100, child: Text('toolbar'))]),
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
    final remainingCenter = (toolbarBottom + 800 - AppSizes.chatLauncherSpace) / 2;
    expect(emptyCenter, closeTo(remainingCenter, 30));
  });

  testWidgets('centerChild อยู่กึ่งกลางแนวนอน', (tester) async {
    await pumpPage(tester, centerChild: const Text('ยังไม่มีสินค้า'));
    expect(tester.getCenter(find.text('ยังไม่มีสินค้า')).dx, closeTo(640, 1));
  });

  Future<void> pumpLongPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageContent(
            header: const Text('กลับไปหน้าสินค้า'),
            children: [for (var i = 0; i < 30; i++) SizedBox(height: 100, child: Text('แถว $i'))],
          ),
        ),
      ),
    );
  }

  bool topButtonShown(WidgetTester tester) {
    final scale = tester.widget<AnimatedScale>(
      find.ancestor(of: find.byType(FloatingActionButton), matching: find.byType(AnimatedScale)),
    );
    return scale.scale == 1;
  }

  testWidgets('header ติดอยู่ด้านบน เลื่อนลงแล้วยังอยู่ที่เดิม', (tester) async {
    await pumpLongPage(tester);
    final headerBefore = tester.getTopLeft(find.text('กลับไปหน้าสินค้า')).dy;
    final rowBefore = tester.getTopLeft(find.text('แถว 5')).dy;
    await tester.drag(find.text('แถว 2'), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('กลับไปหน้าสินค้า')).dy, headerBefore);
    expect(tester.getTopLeft(find.text('แถว 5')).dy, lessThan(rowBefore - 500));
  });

  testWidgets('เลื่อนลงเกินระยะ → มีปุ่มลูกศร กดแล้วกลับขึ้นบนสุด', (tester) async {
    await pumpLongPage(tester);
    expect(topButtonShown(tester), isFalse);

    await tester.drag(find.text('แถว 2'), const Offset(0, -(AppSizes.scrollTopThreshold + 300)));
    await tester.pumpAndSettle();
    expect(topButtonShown(tester), isTrue);

    await tester.tap(find.byTooltip('common.scroll_top'.tr));
    await tester.pumpAndSettle();
    expect(find.text('แถว 0'), findsOneWidget);
    expect(topButtonShown(tester), isFalse);
  });
}

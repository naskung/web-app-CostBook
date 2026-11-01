import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/shared/widgets/molecules/load_more_footer.dart';

void main() {
  late int retried;

  Future<void> pumpFooter(WidgetTester tester, AppStatus status) async {
    retried = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LoadMoreFooter(status: status, retryLabel: 'ลองใหม่', onRetry: () => retried++)),
      ),
    );
  }

  testWidgets('กำลังโหลดเพิ่ม = วงกลมหมุน', (tester) async {
    await pumpFooter(tester, AppStatus.loading);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('โหลดเพิ่มไม่สำเร็จ = ปุ่มลองใหม่ กดแล้วเรียก onRetry', (tester) async {
    await pumpFooter(tester, AppStatus.failure);
    await tester.tap(find.text('ลองใหม่'));
    expect(retried, 1);
  });

  testWidgets('ปกติ / โหลดเสร็จ = ไม่มีอะไร', (tester) async {
    await pumpFooter(tester, AppStatus.success);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('ลองใหม่'), findsNothing);
  });
}

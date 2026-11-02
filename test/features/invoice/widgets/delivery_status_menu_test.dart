import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/delivery_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/invoice/widgets/delivery_status_menu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLang.load('th');
  });

  late List<DeliveryStatus> changes;

  setUp(() {
    changes = [];
  });

  Future<void> pumpMenu(WidgetTester tester, DeliveryStatus status) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: Center(child: DeliveryStatusMenu(status: status, onChanged: changes.add))),
      ),
    );
  }

  testWidgets('แสดงสถานะปัจจุบัน กดแล้วมีให้เลือกครบ 3 สถานะ', (tester) async {
    await pumpMenu(tester, DeliveryStatus.pending);
    expect(find.text('delivery.pending'.tr), findsOneWidget);

    await tester.tap(find.byType(DeliveryStatusMenu));
    await tester.pumpAndSettle();
    expect(find.text('delivery.shipped'.tr), findsOneWidget);
    expect(find.text('delivery.received'.tr), findsOneWidget);
    expect(find.text('delivery.pending'.tr), findsNWidgets(2));
  });

  testWidgets('เลือกสถานะใหม่ ส่งสถานะนั้นออกไป', (tester) async {
    await pumpMenu(tester, DeliveryStatus.pending);
    await tester.tap(find.byType(DeliveryStatusMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('delivery.shipped'.tr));
    await tester.pumpAndSettle();
    expect(changes, [DeliveryStatus.shipped]);
  });

  testWidgets('เลือกสถานะเดิม ไม่ส่งอะไรออกไป (ไม่ยิง API ซ้ำ)', (tester) async {
    await pumpMenu(tester, DeliveryStatus.received);
    await tester.tap(find.byType(DeliveryStatusMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('delivery.received'.tr).last);
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });
}

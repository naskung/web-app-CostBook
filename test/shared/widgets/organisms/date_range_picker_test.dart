import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/shared/widgets/molecules/range_calendar.dart';
import 'package:costbook/shared/widgets/organisms/date_range_panel.dart';
import 'package:costbook/shared/widgets/organisms/date_range_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final october = DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 31));
  late List<DateTimeRange> changes;

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    changes = [];
  });

  Future<void> pumpPicker(WidgetTester tester, Size screenSize) async {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(alignment: Alignment.topLeft, child: DateRangePicker(range: october, onChanged: changes.add)),
          ),
        ),
      ),
    );
  }

  Finder day(String text) => find.descendant(of: find.byType(RangeCalendar), matching: find.text(text));

  testWidgets('ปุ่มแสดงช่วงที่เลือกอยู่ ยังไม่เปิดปฏิทิน', (tester) async {
    await pumpPicker(tester, const Size(1280, 800));
    expect(find.text('ตุลาคม 2569'), findsOneWidget);
    expect(find.byType(DateRangePanel), findsNothing);
  });

  testWidgets('กดปุ่ม เปิดปฏิทินแบบ dropdown / เลือกช่วงแล้วตกลง ปิดและส่งช่วงใหม่', (tester) async {
    await pumpPicker(tester, const Size(1280, 800));
    await tester.tap(find.text('ตุลาคม 2569'));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePanel), findsOneWidget);

    await tester.tap(day('10'));
    await tester.tap(day('20'));
    await tester.pump();
    await tester.tap(find.text('date_range.apply'.tr));
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePanel), findsNothing);
    expect(changes, [DateTimeRange(start: DateTime(2026, 10, 10), end: DateTime(2026, 10, 20))]);
  });

  testWidgets('ตกลงโดยไม่เปลี่ยนอะไร ไม่โหลดใหม่', (tester) async {
    await pumpPicker(tester, const Size(1280, 800));
    await tester.tap(find.text('ตุลาคม 2569'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('date_range.apply'.tr));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  testWidgets('มือถือ 375 เปิดปฏิทินได้ ไม่ล้นจอ', (tester) async {
    await pumpPicker(tester, const Size(375, 812));
    await tester.tap(find.text('ตุลาคม 2569'));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePanel), findsOneWidget);
    expect(tester.takeException(), isNull);
    final panel = tester.getRect(find.byType(DateRangePanel));
    expect(panel.right, lessThanOrEqualTo(375));
  });
}

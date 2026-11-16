import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/shared/widgets/molecules/month_year_grid.dart';
import 'package:costbook/shared/widgets/molecules/range_calendar.dart';
import 'package:costbook/shared/widgets/organisms/date_range_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 11, 16);
  final november = DateTimeRange(start: DateTime(2026, 11, 1), end: DateTime(2026, 11, 30));
  late DateTimeRange? applied;
  late bool cancelled;

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    applied = null;
    cancelled = false;
  });

  Future<void> pumpPanel(WidgetTester tester, {DateTimeRange? initialRange}) {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DateRangePanel(
              initialRange: initialRange ?? november,
              today: today,
              onApply: (range) => applied = range,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      ),
    );
  }

  Finder day(String text) => find.descendant(of: find.byType(RangeCalendar), matching: find.text(text));

  Finder grid(String text) => find.descendant(of: find.byType(MonthYearGrid), matching: find.text(text));

  Future<void> tapApply(WidgetTester tester) async {
    await tester.tap(find.text('date_range.apply'.tr));
    await tester.pump();
  }

  Future<void> openMonthGrid(WidgetTester tester) async {
    await tester.tap(find.descendant(of: find.byType(RangeCalendar), matching: find.text('พฤศจิกายน 2569')));
    await tester.pump();
  }

  testWidgets('กดปุ่มลัดวันนี้ ได้วันนี้ถึงวันนี้ทันที', (tester) async {
    await pumpPanel(tester);
    await tester.tap(find.text('date_range.today'.tr));
    expect(applied, DateTimeRange(start: today, end: today));
  });

  testWidgets('กดปุ่มลัด 7 วันล่าสุด ได้ 10–16 พ.ย.', (tester) async {
    await pumpPanel(tester);
    await tester.tap(find.text('date_range.last_7_days'.tr));
    expect(applied, DateTimeRange(start: DateTime(2026, 11, 10), end: today));
  });

  testWidgets('ปุ่มลัดที่ตรงกับช่วงที่เลือกอยู่ ขึ้นเป็นเลือกแล้ว', (tester) async {
    await pumpPanel(tester);
    final thisMonth = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'date_range.this_month'.tr));
    final today = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'date_range.today'.tr));
    expect(thisMonth.selected, isTrue);
    expect(today.selected, isFalse);
  });

  testWidgets('กดวันแรก แล้ววันสุดท้าย แล้วตกลง ได้ช่วงนั้น', (tester) async {
    await pumpPanel(tester);
    await tester.tap(day('3'));
    await tester.pump();
    expect(find.text('date_range.pick_end'.tr), findsOneWidget);
    await tester.tap(day('9'));
    await tester.pump();
    expect(find.text('3 – 9 พ.ย. 2569'), findsOneWidget);
    expect(find.text('date_range.day_count'.trParams({'count': '7'})), findsOneWidget);
    await tapApply(tester);
    expect(applied, DateTimeRange(start: DateTime(2026, 11, 3), end: DateTime(2026, 11, 9)));
  });

  testWidgets('กดวันเดียวแล้วตกลง ได้วันนั้นวันเดียว', (tester) async {
    await pumpPanel(tester);
    await tester.tap(day('16'));
    await tester.pump();
    await tapApply(tester);
    expect(applied, DateTimeRange(start: today, end: today));
  });

  testWidgets('กดวันหลังก่อนวันแรก สลับให้เป็นช่วงที่ถูก', (tester) async {
    await pumpPanel(tester);
    await tester.tap(day('20'));
    await tester.tap(day('5'));
    await tester.pump();
    await tapApply(tester);
    expect(applied, DateTimeRange(start: DateTime(2026, 11, 5), end: DateTime(2026, 11, 20)));
  });

  testWidgets('เลื่อนไปเดือนก่อน แล้วเลือกข้ามเดือนได้', (tester) async {
    await pumpPanel(tester);
    await tester.tap(day('2'));
    await tester.tap(find.byTooltip('common.previous_month'.tr));
    await tester.pump();
    expect(find.text('ตุลาคม 2569'), findsOneWidget);
    await tester.tap(day('25'));
    await tester.pump();
    await tapApply(tester);
    expect(applied, DateTimeRange(start: DateTime(2026, 10, 25), end: DateTime(2026, 11, 2)));
  });

  testWidgets('ช่วงยาวเกิน 366 วัน กดตกลงไม่ได้ และบอกเหตุผล', (tester) async {
    final tooLong = DateTimeRange(start: DateTime(2025, 1, 1), end: DateTime(2026, 11, 16));
    await pumpPanel(tester, initialRange: tooLong);
    expect(find.text('date_range.too_long'.trParams({'days': '366'})), findsOneWidget);
    final apply = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'date_range.apply'.tr));
    expect(apply.onPressed, isNull);
  });

  testWidgets('กดยกเลิก ไม่เปลี่ยนช่วง', (tester) async {
    await pumpPanel(tester);
    await tester.tap(day('3'));
    await tester.tap(find.text('common.cancel'.tr));
    expect(cancelled, isTrue);
    expect(applied, isNull);
  });

  testWidgets('กดชื่อเดือน เปลี่ยนเป็นตารางเลือกเดือน 12 ช่อง', (tester) async {
    await pumpPanel(tester);
    await openMonthGrid(tester);
    expect(find.byType(RangeCalendar), findsNothing);
    expect(grid('2569'), findsOneWidget);
    for (final month in ['ม.ค.', 'มิ.ย.', 'ธ.ค.']) {
      expect(grid(month), findsOneWidget);
    }
  });

  testWidgets('ตารางเดือน กดเลือกเดือน กลับไปปฏิทินของเดือนนั้น', (tester) async {
    await pumpPanel(tester);
    await openMonthGrid(tester);
    await tester.tap(grid('มี.ค.'));
    await tester.pump();
    expect(find.descendant(of: find.byType(RangeCalendar), matching: find.text('มีนาคม 2569')), findsOneWidget);
  });

  testWidgets('ตารางเดือน ‹ › เปลี่ยนทีละปี', (tester) async {
    await pumpPanel(tester);
    await openMonthGrid(tester);
    await tester.tap(find.byTooltip('date_range.previous_year'.tr));
    await tester.pump();
    expect(grid('2568'), findsOneWidget);
  });

  testWidgets('ย้อนไปไกล ๆ: กดปี → ตารางปีทีละ 12 ปี → เลือกปี → เลือกเดือน → เลือกวัน', (tester) async {
    await pumpPanel(tester);
    await openMonthGrid(tester);
    await tester.tap(grid('2569'));
    await tester.pump();
    expect(grid('2558 – 2569'), findsOneWidget);

    await tester.tap(find.byTooltip('date_range.previous_years'.tr));
    await tester.pump();
    expect(grid('2546 – 2557'), findsOneWidget);
    await tester.tap(grid('2550'));
    await tester.pump();
    expect(grid('2550'), findsOneWidget);
    await tester.tap(grid('มี.ค.'));
    await tester.pump();

    expect(find.descendant(of: find.byType(RangeCalendar), matching: find.text('มีนาคม 2550')), findsOneWidget);
    await tester.tap(day('5'));
    await tester.tap(day('10'));
    await tester.pump();
    await tapApply(tester);
    expect(applied, DateTimeRange(start: DateTime(2007, 3, 5), end: DateTime(2007, 3, 10)));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';

void main() {
  const columns = [
    AppDataColumn(label: 'ชื่อ', flex: 3, minWidth: 300),
    AppDataColumn(label: 'ราคา', minWidth: 200),
    AppDataColumn(label: 'ปุ่ม', width: 80),
  ];
  const minWidth = AppSizes.spaceMedium * 2 + AppSizes.spaceMedium * 2 + 300 + 200 + 80;

  Future<void> pumpTable(WidgetTester tester, double screenWidth) async {
    tester.view.physicalSize = Size(screenWidth, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppDataTable(
            columns: columns,
            rows: [
              [Text('พวงกุญแจ'), Text('125.26'), SizedBox(key: Key('actions'), width: 80, height: 40)],
            ],
          ),
        ),
      ),
    );
  }

  Finder horizontalScroll() {
    return find.byWidgetPredicate(
      (widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal,
    );
  }

  Rect actionsRect(WidgetTester tester) => tester.getRect(find.byKey(const Key('actions')));

  testWidgets('จอกว้างพอ ไม่มีเลื่อนซ้าย-ขวา / คอลัมน์ที่ใส่ width กว้างเท่านั้นพอดี', (tester) async {
    await pumpTable(tester, 1200);
    expect(horizontalScroll(), findsNothing);
    final actionsCell = find.ancestor(of: find.byKey(const Key('actions')), matching: find.byType(SizedBox)).first;
    expect(tester.getSize(actionsCell).width, 80);
  });

  testWidgets('คอลัมน์ได้ความกว้างแคบสุดของตัวเองก่อน แล้วแบ่งที่เหลือตาม flex (ไม่แคบกว่า minWidth แม้ flex น้อย)', (
    tester,
  ) async {
    await pumpTable(tester, minWidth + 82);
    final name = tester.getRect(find.text('พวงกุญแจ')).left;
    final price = tester.getRect(find.text('125.26')).left;
    final actions = actionsRect(tester).left;
    final nameWidth = price - name - AppSizes.spaceMedium;
    final priceWidth = actions - price - AppSizes.spaceMedium;
    expect(horizontalScroll(), findsNothing);
    expect(nameWidth, greaterThanOrEqualTo(300));
    expect(priceWidth, greaterThanOrEqualTo(200));
    expect(nameWidth - 300, closeTo((priceWidth - 200) * 3, 3));
  });

  testWidgets('หัวคอลัมน์ชิดขวาเหมือนข้อมูล ทั้งตอนบรรทัดเดียวและตกบรรทัด', (tester) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppDataTable(
            columns: [
              AppDataColumn(label: 'ชื่อ', flex: 3),
              AppDataColumn(label: 'ราคาขายต่อหน่วยแบบยาวมาก', alignEnd: true, minWidth: 80),
            ],
            rows: [
              [Text('พวงกุญแจ'), Text('59.00')],
            ],
          ),
        ),
      ),
    );
    final header = tester.widget<Text>(find.text('ราคาขายต่อหน่วยแบบยาวมาก'));
    expect(header.textAlign, TextAlign.end);
    expect(tester.getRect(find.text('ราคาขายต่อหน่วยแบบยาวมาก')).right, tester.getRect(find.text('59.00')).right);
  });

  testWidgets('จอแคบกว่าความกว้างแคบสุดของตาราง → ตารางกว้างเท่าเดิม เลื่อนซ้าย-ขวาไปดูคอลัมน์ท้ายได้', (tester) async {
    await pumpTable(tester, 600);
    expect(tester.takeException(), isNull);
    expect(horizontalScroll(), findsOneWidget);
    final table = find.descendant(of: horizontalScroll(), matching: find.byType(Column)).first;
    expect(tester.getSize(table).width, minWidth);
    expect(actionsRect(tester).right, greaterThan(600));

    await tester.drag(horizontalScroll(), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(actionsRect(tester).right, lessThanOrEqualTo(600));
  });
}

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

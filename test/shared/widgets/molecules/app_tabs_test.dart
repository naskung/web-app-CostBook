import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/shared/widgets/molecules/app_tabs.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';

void main() {
  const tabs = [
    AppTab(value: '', label: 'ทั้งหมด', icon: Icons.grid_view_rounded, count: 6),
    AppTab(value: 'sale', label: 'สินค้าขาย', icon: Icons.sell_outlined, count: 4),
    AppTab(value: 'material', label: 'วัสดุ', icon: Icons.layers_outlined, count: 2),
  ];

  Future<void> pumpTabs(WidgetTester tester, {String selected = '', ValueChanged<String>? onChanged}) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AppTabs(tabs: tabs, selected: selected, onChanged: onChanged ?? (_) {}))),
    );
  }

  Color labelColor(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style?.color ?? AppColors.transparent;

  testWidgets('แสดงชื่อแท็บและจำนวนของแต่ละแท็บ', (tester) async {
    await pumpTabs(tester);
    for (final text in ['ทั้งหมด', 'สินค้าขาย', 'วัสดุ', '6', '4', '2']) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('แท็บที่เลือก ตัวหนังสือส้มเข้ม / แท็บอื่นสีเทา', (tester) async {
    await pumpTabs(tester, selected: 'material');
    expect(labelColor(tester, 'วัสดุ'), AppColors.primaryDark);
    expect(labelColor(tester, 'ทั้งหมด'), AppColors.textSecondary);
  });

  testWidgets('กดแท็บ ส่งค่าของแท็บนั้นกลับมา', (tester) async {
    final changed = <String>[];
    await pumpTabs(tester, onChanged: changed.add);
    await tester.tap(find.text('สินค้าขาย'));
    await tester.tap(find.text('วัสดุ'));
    expect(changed, ['sale', 'material']);
  });

  testWidgets('จอคอมแสดงไอคอนแท็บ / มือถือไม่แสดง (แท็บพอดีจอ)', (tester) async {
    await pumpTabs(tester);
    expect(find.byIcon(Icons.layers_outlined), findsOneWidget);

    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpTabs(tester);
    expect(find.byIcon(Icons.layers_outlined), findsNothing);
    expect(find.text('วัสดุ'), findsOneWidget);
  });

  testWidgets('AppDataTable ใส่แท็บไว้บนสุดของตารางได้ (header)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDataTable(
            header: AppTabs(tabs: tabs, selected: '', onChanged: (_) {}),
            columns: const [AppDataColumn(label: 'ชื่อสินค้า')],
            rows: const [
              [Text('พวงกุญแจ')],
            ],
          ),
        ),
      ),
    );
    final tabsTop = tester.getTopLeft(find.byType(AppTabs)).dy;
    final headerTop = tester.getTopLeft(find.text('ชื่อสินค้า')).dy;
    expect(tabsTop, lessThan(headerTop));
    expect(find.text('พวงกุญแจ'), findsOneWidget);
  });
}

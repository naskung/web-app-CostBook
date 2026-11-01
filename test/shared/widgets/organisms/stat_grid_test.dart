import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/shared/widgets/molecules/stat_card.dart';
import 'package:costbook/shared/widgets/organisms/stat_grid.dart';

void main() {
  StatCard card(String label, {String? caption}) {
    return StatCard(
      key: ValueKey(label),
      label: label,
      value: '239.13',
      icon: Icons.south_west,
      color: AppColors.success,
      backgroundColor: AppColors.successSoft,
      caption: caption,
    );
  }

  Future<void> pumpGrid(WidgetTester tester, List<Widget> cards, {double width = 1000}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: width, child: StatGrid(maxColumns: 4, minCardWidth: 220, children: cards)),
          ),
        ),
      ),
    );
  }

  double heightOf(WidgetTester tester, String label) => tester.getSize(find.byKey(ValueKey(label))).height;

  testWidgets('การ์ดในแถวเดียวกันสูงเท่ากัน แม้คำอธิบายยาวไม่เท่ากัน / ไม่มีคำอธิบาย', (tester) async {
    await pumpGrid(tester, [
      card('รายได้', caption: 'ขายสินค้า 239.13 + รายรับอื่น 0.00 ขายสินค้า 239.13 + รายรับอื่น 0.00'),
      card('ต้นทุน', caption: 'กำไรขั้นต้น 11.39'),
      card('รายจ่าย'),
      card('กำไรสุทธิ', caption: 'รายได้ − ต้นทุนสินค้า − รายจ่าย'),
    ]);
    final heights = ['รายได้', 'ต้นทุน', 'รายจ่าย', 'กำไรสุทธิ'].map((label) => heightOf(tester, label)).toSet();
    expect(heights.length, 1);
  });

  testWidgets('จอแคบ 2 คอลัมน์ การ์ดกว้างเท่ากัน แถวสุดท้ายที่ไม่ครบก็กว้างเท่าเดิม', (tester) async {
    await pumpGrid(tester, [card('a'), card('b'), card('c')], width: 500);
    final first = tester.getSize(find.byKey(const ValueKey('a')));
    final last = tester.getSize(find.byKey(const ValueKey('c')));
    expect(last.width, first.width);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('c'))).dy,
      greaterThan(tester.getTopLeft(find.byKey(const ValueKey('a'))).dy),
    );
  });
}

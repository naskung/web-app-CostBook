import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/shared/widgets/molecules/stat_card.dart';
import 'package:costbook/shared/widgets/organisms/stat_grid.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, StatCard card) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: StatGrid(maxColumns: 1, children: [card]))));
  }

  StatCard card({double? share, bool isHighlighted = false, Color? valueColor}) {
    return StatCard(
      label: 'ต้นทุนสินค้าที่ขาย',
      value: '227.74',
      icon: Icons.inventory_2_outlined,
      color: AppColors.info,
      backgroundColor: AppColors.infoSoft,
      caption: 'กำไรขั้นต้น 11.39',
      share: share,
      shareLabel: share == null ? '' : '95.2% ของรายได้',
      isHighlighted: isHighlighted,
      valueColor: valueColor,
    );
  }

  Color valueColorOf(WidgetTester tester) =>
      tester.widget<Text>(find.text('227.74')).style?.color ?? AppColors.transparent;

  testWidgets('มี share → แสดงแถบสัดส่วนยาวตาม % + ข้อความข้างแถบ', (tester) async {
    await pumpCard(tester, card(share: 95.2));
    final meter = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(meter.value, closeTo(0.952, 0.0001));
    expect(meter.color, AppColors.info);
    expect(find.text('95.2% ของรายได้'), findsOneWidget);
  });

  testWidgets('ไม่มี share → ไม่มีแถบ', (tester) async {
    await pumpCard(tester, card());
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('การ์ดปกติ ตัวเลขสีเข้ม / การ์ดผลลัพธ์ (isHighlighted) ตัวเลขสีขาวบนพื้นเข้ม', (tester) async {
    await pumpCard(tester, card(share: 5));
    expect(valueColorOf(tester), AppColors.textPrimary);

    await pumpCard(tester, card(share: 5, isHighlighted: true));
    expect(valueColorOf(tester), AppColors.onDark);
  });

  testWidgets('ขาดทุน: ส่ง valueColor มาเปลี่ยนสีตัวเลขได้', (tester) async {
    await pumpCard(tester, card(share: -5, isHighlighted: true, valueColor: AppColors.dangerOnDark));
    expect(valueColorOf(tester), AppColors.dangerOnDark);
    expect(tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value, 0);
  });
}

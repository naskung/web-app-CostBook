import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';

void main() {
  Future<void> pumpButton(WidgetTester tester, AppButton button) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: button))));
  }

  testWidgets('ค่าเริ่มต้นเป็นปุ่มหลัก กดแล้วเรียก onPressed', (tester) async {
    var pressed = 0;
    await pumpButton(tester, AppButton(text: 'บันทึก', onPressed: () => pressed++));
    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, 1);
  });

  testWidgets('secondary เป็นปุ่มขอบ', (tester) async {
    await pumpButton(tester, AppButton(text: 'ยกเลิก', variant: AppButtonVariant.secondary, onPressed: () {}));
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('danger เป็นปุ่มสีแดง', (tester) async {
    await pumpButton(tester, AppButton(text: 'ลบ', variant: AppButtonVariant.danger, onPressed: () {}));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.style?.backgroundColor?.resolve({}), AppColors.danger);
  });

  testWidgets('มี icon แสดง icon หน้าข้อความ', (tester) async {
    await pumpButton(tester, AppButton(text: 'เพิ่ม', icon: Icons.add, onPressed: () {}));
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('เพิ่ม'), findsOneWidget);
  });

  testWidgets('กำลังโหลด แสดงวงหมุนและกดไม่ได้', (tester) async {
    var pressed = 0;
    await pumpButton(tester, AppButton(text: 'บันทึก', isLoading: true, onPressed: () => pressed++));
    await tester.tap(find.byType(ElevatedButton));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(pressed, 0);
  });
}

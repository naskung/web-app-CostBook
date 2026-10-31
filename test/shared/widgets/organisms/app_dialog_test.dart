import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/shared/widgets/organisms/app_dialog.dart';

void main() {
  Future<void> openDialog(WidgetTester tester, AppDialog dialog, {Size size = const Size(1280, 800)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed: () => showDialog<void>(context: context, builder: (_) => dialog),
                child: const Text('เปิด'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('เปิด'));
    await tester.pumpAndSettle();
  }

  const actions = [Text('ยกเลิก'), Text('บันทึก')];

  testWidgets('แสดงชื่อ คำอธิบาย ไอคอน เนื้อหา และปุ่มด้านล่าง', (tester) async {
    await openDialog(
      tester,
      const AppDialog(
        title: 'เพิ่มสินค้า',
        subtitle: 'กรอกข้อมูลสินค้า',
        icon: Icons.inventory_2_outlined,
        actions: actions,
        child: Text('ฟอร์ม'),
      ),
    );
    expect(find.text('เพิ่มสินค้า'), findsOneWidget);
    expect(find.text('กรอกข้อมูลสินค้า'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.text('ฟอร์ม'), findsOneWidget);
    expect(find.text('บันทึก'), findsOneWidget);
  });

  testWidgets('กดปุ่มปิด (X) แล้ว dialog หายไป', (tester) async {
    await openDialog(tester, const AppDialog(title: 'เพิ่มสินค้า', child: Text('ฟอร์ม')));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('ฟอร์ม'), findsNothing);
  });

  testWidgets('canClose = false (กำลังบันทึก) กดปุ่มปิดไม่ได้', (tester) async {
    await openDialog(tester, const AppDialog(title: 'เพิ่มสินค้า', canClose: false, child: Text('ฟอร์ม')));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('ฟอร์ม'), findsOneWidget);
  });

  testWidgets('จอมือถือ ปุ่มด้านล่างกว้างเท่ากัน', (tester) async {
    await openDialog(
      tester,
      const AppDialog(title: 'เพิ่มสินค้า', actions: actions, child: Text('ฟอร์ม')),
      size: const Size(375, 700),
    );
    final cancelWidth = tester.getSize(find.ancestor(of: find.text('ยกเลิก'), matching: find.byType(Expanded))).width;
    final saveWidth = tester.getSize(find.ancestor(of: find.text('บันทึก'), matching: find.byType(Expanded))).width;
    expect(cancelWidth, saveWidth);
  });
}

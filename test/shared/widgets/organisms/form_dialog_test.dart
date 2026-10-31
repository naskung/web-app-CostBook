import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

void main() {
  Future<void> openDialog(
    WidgetTester tester, {
    bool isSaving = false,
    String errorText = '',
    VoidCallback? onSave,
  }) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder:
                          (_) => FormDialog(
                            title: 'เพิ่มสินค้า',
                            saveLabel: 'บันทึก',
                            cancelLabel: 'ยกเลิก',
                            isSaving: isSaving,
                            errorText: errorText,
                            onSave: onSave ?? () {},
                            child: const Text('ฟอร์ม'),
                          ),
                    ),
                child: const Text('เปิด'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('เปิด'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('กดบันทึก เรียก onSave', (tester) async {
    var saved = 0;
    await openDialog(tester, onSave: () => saved++);
    await tester.tap(find.text('บันทึก'));
    expect(saved, 1);
  });

  testWidgets('กดยกเลิก แล้ว dialog หายไป', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('ยกเลิก'));
    await tester.pumpAndSettle();
    expect(find.text('ฟอร์ม'), findsNothing);
  });

  testWidgets('มี errorText ขึ้นกล่อง error', (tester) async {
    await openDialog(tester, errorText: 'ชื่อสินค้าซ้ำ');
    expect(find.text('ชื่อสินค้าซ้ำ'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('กำลังบันทึก กดยกเลิกไม่ได้ dialog ยังอยู่', (tester) async {
    await openDialog(tester, isSaving: true);
    await tester.tap(find.text('ยกเลิก'));
    await tester.pump();
    expect(find.text('ฟอร์ม'), findsOneWidget);
  });
}

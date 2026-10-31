import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/helpers/dialog_helper.dart';

void main() {
  Future<List<bool>> openConfirm(WidgetTester tester) async {
    final results = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed: () async {
                  results.add(
                    await DialogHelper.confirm(
                      context,
                      title: 'ลบสินค้า',
                      message: 'ลบแล้วกู้คืนไม่ได้',
                      confirmText: 'ลบ',
                    ),
                  );
                },
                child: const Text('เปิด'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('เปิด'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('แสดงชื่อ ข้อความ และไอคอนลบเป็นค่าเริ่มต้น', (tester) async {
    await openConfirm(tester);
    expect(find.text('ลบสินค้า'), findsOneWidget);
    expect(find.text('ลบแล้วกู้คืนไม่ได้'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('กดยืนยัน ได้ true', (tester) async {
    final results = await openConfirm(tester);
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();
    expect(results, [true]);
  });

  testWidgets('กดยกเลิก ได้ false', (tester) async {
    final results = await openConfirm(tester);
    await tester.tap(find.text('common.cancel'));
    await tester.pumpAndSettle();
    expect(results, [false]);
  });
}

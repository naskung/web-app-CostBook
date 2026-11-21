import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/molecules/search_field.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required String value, required ValueChanged<String> onChanged}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SearchField(hint: 'ค้นหา', value: value, onChanged: onChanged, suffix: const Icon(Icons.qr_code)),
        ),
      ),
    );
  }

  String text(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).controller?.text ?? '';

  testWidgets('พิมพ์แล้วส่งคำค้นออกไป / มีปุ่มท้ายช่อง', (tester) async {
    final queries = <String>[];
    await pump(tester, value: '', onChanged: queries.add);
    await tester.enterText(find.byType(TextField), 'PLA');
    expect(queries, ['PLA']);
    expect(find.byIcon(Icons.qr_code), findsOneWidget);
  });

  testWidgets('คำค้นเปลี่ยนจากที่อื่น (เช่น สแกนบาร์โค้ด) ช่องแสดงตาม', (tester) async {
    await pump(tester, value: '', onChanged: (_) {});
    expect(text(tester), '');
    await pump(tester, value: '8851234567890', onChanged: (_) {});
    expect(text(tester), '8851234567890');
  });
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/shared/widgets/atoms/app_image_box.dart';

void main() {
  // PNG 1 × 1 px ไว้ทดสอบ Image.memory
  final onePixelPng = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, //
    137, 0, 0, 0, 13, 73, 68, 65, 84, 120, 156, 99, 248, 15, 4, 0, 9, 251, 3, 253, 227, 85, 242, 156, 0, 0, 0, 0, 73, //
    69, 78, 68, 174, 66, 96, 130,
  ]);

  Future<void> pumpBox(WidgetTester tester, AppImageBox box) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: box))));
  }

  testWidgets('ไม่มีรูป แสดงกล่องไอคอนแทน', (tester) async {
    await pumpBox(tester, const AppImageBox(width: 40, height: 40, placeholderIcon: Icons.inventory_2_outlined));
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('มีรูปที่เพิ่งเลือก แสดงรูปนั้น', (tester) async {
    await pumpBox(tester, AppImageBox(bytes: onePixelPng, width: 40, height: 40));
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsNothing);
  });

  testWidgets('กำหนดขนาดได้ตามที่ส่ง', (tester) async {
    await pumpBox(tester, const AppImageBox(width: 112, height: 112));
    expect(tester.getSize(find.byType(AppImageBox)), const Size(112, 112));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/sell/widgets/sell_product_tile.dart';

void main() {
  Widget tile(String name, {VoidCallback? onTap, int quantityInCart = 0}) {
    return SellProductTile(
      quantityInCart: quantityInCart,
      key: ValueKey(name),
      image: const SizedBox(height: 96),
      name: name,
      price: 99,
      stockText: 'คงเหลือ 0',
      width: 140,
      isOut: true,
      onTap: onTap ?? () {},
    );
  }

  testWidgets('ชื่อสั้น 1 บรรทัด กับชื่อยาว 2 บรรทัด การ์ดสูงเท่ากัน', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Wrap(children: [tile('แก้ว'), tile('เคสมือถือ iPhone 13 Pro Max ลายการ์ตูน')]))),
    );
    final short = tester.getSize(find.byKey(const ValueKey('แก้ว')));
    final long = tester.getSize(find.byKey(const ValueKey('เคสมือถือ iPhone 13 Pro Max ลายการ์ตูน')));
    expect(short.height, long.height);
  });

  testWidgets('กดการ์ด เรียก onTap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: tile('พวงกุญแจ', onTap: () => tapped++))));
    await tester.tap(find.text('พวงกุญแจ'));
    expect(tapped, 1);
  });

  testWidgets('อยู่ในบิลแล้ว มีวงกลมบอกจำนวน / ยังไม่อยู่ ไม่มี', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Row(children: [tile('พวงกุญแจ', quantityInCart: 3), tile('แจกัน')]))),
    );
    expect(find.text('3'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}

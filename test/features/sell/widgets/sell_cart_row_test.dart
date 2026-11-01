import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/sell/widgets/sell_cart_row.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLang.load('th');
  });

  late List<int> quantities;
  late int removed;
  late int edited;

  setUp(() {
    quantities = [];
    removed = 0;
    edited = 0;
  });

  Future<void> pumpRow(WidgetTester tester, InvoiceDraftItemModel item) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SellCartRow(
            item: item,
            onQuantityChanged: quantities.add,
            onRemove: () => removed++,
            onEdit: () => edited++,
          ),
        ),
      ),
    );
  }

  const twoKeychains = InvoiceDraftItemModel(
    productId: 'p1',
    name: 'พวงกุญแจ',
    unit: 'ชิ้น',
    stock: 8,
    quantity: 2,
    unitPrice: 59,
  );

  testWidgets('แสดงชื่อ ราคาต่อหน่วย จำนวน และยอดรวมของแถว', (tester) async {
    await pumpRow(tester, twoKeychains);
    expect(find.text('พวงกุญแจ'), findsOneWidget);
    expect(find.text('sell.unit_price'.trParams({'price': '59.00', 'unit': 'ชิ้น'})), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('118.00'), findsOneWidget);
  });

  testWidgets('กด + / − เปลี่ยนจำนวนทีละ 1', (tester) async {
    await pumpRow(tester, twoKeychains);
    await tester.tap(find.byTooltip('sell.increase'.tr));
    await tester.tap(find.byTooltip('sell.decrease'.tr));
    expect(quantities, [3, 1]);
  });

  testWidgets('เหลือ 1 ชิ้น ปุ่ม − กลายเป็นถังขยะ กดแล้วเอาออกจากบิล', (tester) async {
    await pumpRow(tester, twoKeychains.copyWith(quantity: 1));
    expect(find.byTooltip('sell.decrease'.tr), findsNothing);
    await tester.tap(find.byTooltip('sell.remove_item'.tr));
    expect(removed, 1);
    expect(quantities, isEmpty);
  });

  testWidgets('กดชื่อสินค้า เปิดแก้รายการ / ขายเกินคงเหลือ มีข้อความเตือน', (tester) async {
    await pumpRow(tester, twoKeychains.copyWith(quantity: 9));
    expect(find.text('sell.over_stock'.trParams({'stock': '8'})), findsOneWidget);
    await tester.tap(find.text('พวงกุญแจ'));
    expect(edited, 1);
  });
}

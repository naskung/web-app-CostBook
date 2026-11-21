import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_mobile_card.dart';

void main() {
  setUpAll(() async {
    await AppLang.load('th');
  });

  Future<void> pumpCard(
    WidgetTester tester,
    ProductModel product, {
    List<String> fields = const [],
    VoidCallback? onMove,
  }) {
    tester.view.physicalSize = const Size(375, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ProductMobileCard(
            product: product,
            fieldTexts: fields,
            menu: const Icon(Icons.more_vert),
            onStockMove: onMove,
          ),
        ),
      ),
    );
  }

  testWidgets('สินค้าขาย: ต้นทุน / ราคาขาย / คงเหลือ (มีคอมม่า) อยู่ในกล่องเดียว + ปุ่มรับเข้า / เบิกออก', (
    tester,
  ) async {
    var moved = 0;
    const keychain = ProductModel(
      code: '885123',
      name: 'พวงกุญแจ',
      unit: 'ชิ้น',
      category: 'งานพิมพ์ 3D',
      costPrice: 18.5,
      sellPrice: 59,
      stock: 1200,
    );
    await pumpCard(tester, keychain, onMove: () => moved++);
    expect(find.text('885123 · งานพิมพ์ 3D'), findsOneWidget);
    expect(find.text('product.table_cost'.tr), findsOneWidget);
    expect(find.text('18.50'), findsOneWidget);
    expect(find.text('product.table_price'.tr), findsOneWidget);
    expect(find.text('59.00'), findsOneWidget);
    expect(find.text('1,200 ชิ้น'), findsOneWidget);
    expect(find.text('product.low'.tr), findsNothing);

    await tester.tap(find.byTooltip('stock.move'.tr));
    expect(moved, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('วัสดุ: ป้ายวัสดุ ไม่มีราคาขาย / ใกล้หมด = ป้ายใกล้หมด / โชว์ช่องเพิ่มเติมที่มีค่า', (tester) async {
    const pla = ProductModel(name: 'PLA', unit: 'กรัม', costPrice: 0.28, stock: 100, minStock: 200, forSale: false);
    await pumpCard(tester, pla, fields: ['ยี่ห้อ R3D', 'สี ดำ'], onMove: () {});
    expect(find.text('product.kind_material'.tr), findsOneWidget);
    expect(find.text('product.table_price'.tr), findsNothing);
    expect(find.text('product.low'.tr), findsOneWidget);
    expect(find.text('product.out_of_stock'.tr), findsNothing);
    expect(find.text('ยี่ห้อ R3D · สี ดำ'), findsOneWidget);
  });

  testWidgets('เหลือ 0 = ป้ายหมดแล้ว ไม่ใช่ป้ายใกล้หมด', (tester) async {
    const soldOut = ProductModel(name: 'พวงกุญแจ', unit: 'ชิ้น', sellPrice: 59, stock: 0, minStock: 5);
    await pumpCard(tester, soldOut, onMove: () {});
    expect(find.text('product.out_of_stock'.tr), findsOneWidget);
    expect(find.text('product.low'.tr), findsNothing);
  });

  testWidgets('ไม่นับสต็อก: บอกว่าไม่นับ และไม่มีปุ่มรับเข้า / เบิกออก', (tester) async {
    const service = ProductModel(name: 'ค่าออกแบบ', sellPrice: 300, trackStock: false);
    await pumpCard(tester, service);
    expect(find.text('product.no_stock'.tr), findsOneWidget);
    expect(find.byTooltip('stock.move'.tr), findsNothing);
  });
}

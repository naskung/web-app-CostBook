import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_form_dialog.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';

class MockProductBloc extends MockBloc<ProductEvent, ProductState> implements ProductBloc {}

void main() {
  const material = ProductFieldModel(id: 'f1', name: 'วัสดุ', type: ProductFieldModel.text);

  setUpAll(() async {
    await AppLang.load('th');
    registerFallbackValue(ProductSaved(const ProductModel(name: '')));
  });

  Future<MockProductBloc> pumpForm(
    WidgetTester tester,
    List<String> order, {
    ProductModel product = const ProductModel(name: ''),
  }) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final bloc = MockProductBloc();
    whenListen(bloc, const Stream<ProductState>.empty(), initialState: const ProductState());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BlocProvider<ProductBloc>.value(
            value: bloc,
            child: ProductFormDialog(product: product, fields: const [material], categories: const [], order: order),
          ),
        ),
      ),
    );
    return bloc;
  }

  double top(WidgetTester tester, String text) => tester.getTopLeft(find.text(text)).dy;

  testWidgets('ไม่มีลำดับที่บันทึกไว้ = แบบเดิม: ช่องที่ร้านเพิ่มอยู่ท้ายฟอร์ม', (tester) async {
    await pumpForm(tester, const []);
    expect(top(tester, 'วัสดุ'), greaterThan(top(tester, 'product.description'.tr)));
  });

  testWidgets('ร้านย้าย "วัสดุ" ไปไว้ใต้ชื่อสินค้า → ฟอร์มจริงเรียงตามนั้น', (tester) async {
    await pumpForm(tester, const [
      'image',
      'name',
      'f1',
      'code_category',
      'unit',
      'prices',
      'sale_stock',
      'description',
    ]);
    expect(top(tester, 'วัสดุ'), greaterThan(top(tester, 'product.name'.tr)));
    expect(top(tester, 'วัสดุ'), lessThan(top(tester, 'product.code'.tr)));
  });

  testWidgets('ย้ายช่องหลักได้ด้วย: คำอธิบายขึ้นไปไว้บนสุด', (tester) async {
    await pumpForm(tester, const [
      'description',
      'image',
      'name',
      'code_category',
      'unit',
      'prices',
      'sale_stock',
      'f1',
    ]);
    expect(top(tester, 'product.description'.tr), lessThan(top(tester, 'product.image'.tr)));
  });

  Finder field(String label) {
    return find.descendant(of: find.widgetWithText(AppTextField, label), matching: find.byType(TextFormField));
  }

  String textOf(WidgetTester tester, String label) {
    return tester.widget<TextFormField>(field(label)).controller?.text ?? '';
  }

  testWidgets('คิดต้นทุนจากราคาที่ซื้อ: ซื้อ 450 บาท ได้ 1000 กรัม → ต้นทุน/หน่วย 0.45', (tester) async {
    await pumpForm(tester, const []);
    expect(field('product.purchase_price'.tr), findsNothing);

    await tester.enterText(field('common.unit'.tr), 'กรัม');
    await tester.tap(find.text('product.purchase_open'.tr));
    await tester.pumpAndSettle();
    expect(find.text('product.purchase_hint'.tr), findsOneWidget);

    await tester.enterText(field('product.purchase_price'.tr), '450');
    await tester.enterText(field('product.purchase_quantity'.tr), '1000');
    await tester.pump();

    expect(textOf(tester, 'product.cost_price'.tr), '0.45');
    final result = 'product.purchase_result'.trParams({
      'price': '450',
      'quantity': '1,000',
      'cost': '0.45',
      'unit': 'กรัม',
    });
    expect(find.text(result), findsOneWidget);
  });

  testWidgets('คิดจากราคาที่ซื้อ หารไม่ลงตัว ปัด 2 ตำแหน่ง / ปิดกล่องแล้วต้นทุนที่ใส่ไว้ยังอยู่', (tester) async {
    await pumpForm(tester, const []);
    await tester.tap(find.text('product.purchase_open'.tr));
    await tester.pumpAndSettle();
    await tester.enterText(field('product.purchase_price'.tr), '100');
    await tester.enterText(field('product.purchase_quantity'.tr), '3');
    await tester.pump();
    expect(textOf(tester, 'product.cost_price'.tr), '33.33');

    await tester.tap(find.byTooltip('common.close'.tr));
    await tester.pumpAndSettle();
    expect(field('product.purchase_price'.tr), findsNothing);
    expect(textOf(tester, 'product.cost_price'.tr), '33.33');
  });

  testWidgets('วัสดุ (ไม่ได้ขาย) ไม่มีช่องราคาขาย / เปิด "ขายสินค้านี้" แล้วช่องราคาขายกลับมา', (tester) async {
    const pla = ProductModel(id: 'p1', name: 'PLA', unit: 'กรัม', sellPrice: 280, forSale: false);
    await pumpForm(tester, const [], product: pla);
    expect(field('product.sell_price'.tr), findsNothing);
    expect(find.text('product.sell_price_material_note'.tr), findsOneWidget);

    await tester.tap(find.text('product.for_sale'.tr));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'product.sell_price'.tr), '280.0');
    expect(find.text('product.sell_price_material_note'.tr), findsNothing);
  });

  testWidgets('บันทึกวัสดุ ส่งราคาขาย 0 (ไม่เก็บค่าที่ซ่อนอยู่) / สินค้าขายส่งราคาขายตามที่กรอก', (tester) async {
    const pla = ProductModel(id: 'p1', name: 'PLA', unit: 'กรัม', sellPrice: 280, forSale: false);
    final bloc = await pumpForm(tester, const [], product: pla);
    await tester.tap(find.text('common.save'.tr));
    await tester.pump();
    var saved = verify(() => bloc.add(captureAny())).captured.last as ProductSaved;
    expect(saved.product.sellPrice, 0);
    expect(saved.product.forSale, isFalse);

    await tester.tap(find.text('product.for_sale'.tr));
    await tester.pumpAndSettle();
    await tester.tap(find.text('common.save'.tr));
    await tester.pump();
    saved = verify(() => bloc.add(captureAny())).captured.last as ProductSaved;
    expect(saved.product.sellPrice, 280);
  });
}

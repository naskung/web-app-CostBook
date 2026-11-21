import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/barcode_product_model.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_form_dialog.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/barcode_scan_button.dart';

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
    Stream<ProductState> states = const Stream<ProductState>.empty(),
  }) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final bloc = MockProductBloc();
    whenListen(bloc, states, initialState: const ProductState());
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

  testWidgets('ช่องรหัส / บาร์โค้ดมีปุ่มสแกนด้วยกล้อง สแกนได้แล้วใส่รหัสลงช่อง', (tester) async {
    await pumpForm(tester, const []);
    final button = find.descendant(
      of: find.widgetWithText(AppTextField, 'product.code'.tr),
      matching: find.byType(BarcodeScanButton),
    );
    expect(button, findsOneWidget);

    tester.widget<BarcodeScanButton>(button).onScanned('8851234567890');
    await tester.pump();
    expect(textOf(tester, 'product.code'.tr), '8851234567890');
  });

  group('สแกนบาร์โค้ดแล้วหาชื่อสินค้าให้', () {
    const code = '8850124003850';
    const water = BarcodeProductModel(code: code, name: 'Nestle Pure Life', brand: 'Nestlé', quantity: '600 mL');

    BarcodeScanButton scanButton(WidgetTester tester) {
      return tester.widget<BarcodeScanButton>(
        find.descendant(
          of: find.widgetWithText(AppTextField, 'product.code'.tr),
          matching: find.byType(BarcodeScanButton),
        ),
      );
    }

    testWidgets('สินค้าใหม่ (ยังไม่มีชื่อ) สแกนเลขสากล → สั่งหา เจอแล้วกรอกชื่อ + ยี่ห้อ · ขนาด ในคำอธิบาย', (
      tester,
    ) async {
      final states = StreamController<ProductState>();
      addTearDown(states.close);
      final bloc = await pumpForm(tester, const [], states: states.stream);

      scanButton(tester).onScanned(code);
      await tester.pump();
      final event = verify(() => bloc.add(captureAny())).captured.last as ProductBarcodeLookupRequested;
      expect(event.code, code);

      states.add(const ProductState(barcodeCode: code, barcodeStatus: AppStatus.loading));
      await tester.pump();
      expect(find.text('product.barcode_searching'.tr), findsOneWidget);

      states.add(const ProductState(barcodeCode: code, barcodeStatus: AppStatus.success, barcodeProduct: water));
      await tester.pump();
      expect(textOf(tester, 'product.name'.tr), 'Nestle Pure Life');
      expect(textOf(tester, 'product.description'.tr), 'Nestlé · 600 mL');
      expect(find.text('product.barcode_found'.tr), findsOneWidget);
    });

    testWidgets('ไม่เจอ → ขึ้นบอกให้กรอกเอง ชื่อยังว่าง', (tester) async {
      final states = StreamController<ProductState>();
      addTearDown(states.close);
      await pumpForm(tester, const [], states: states.stream);

      scanButton(tester).onScanned(code);
      await tester.pump();
      states.add(
        const ProductState(barcodeCode: code, barcodeStatus: AppStatus.failure, barcodeErrorCode: 'barcode_not_found'),
      );
      await tester.pump();
      expect(find.text('error.barcode_not_found'.tr), findsOneWidget);
      expect(textOf(tester, 'product.name'.tr), '');
    });

    testWidgets('แก้สินค้าที่มีชื่อแล้ว สแกนใหม่ → ใส่รหัสอย่างเดียว ไม่สั่งหา (ไม่ทับชื่อเดิม)', (tester) async {
      final bloc = await pumpForm(tester, const [], product: const ProductModel(id: 'p1', name: 'น้ำดื่มร้านเรา'));
      scanButton(tester).onScanned(code);
      await tester.pump();
      expect(textOf(tester, 'product.code'.tr), code);
      verifyNever(() => bloc.add(any(that: isA<ProductBarcodeLookupRequested>())));
    });

    testWidgets('รหัสที่ร้านตั้งเอง (CF001) ไม่ใช่เลขสากล → ไม่สั่งหา', (tester) async {
      final bloc = await pumpForm(tester, const []);
      scanButton(tester).onScanned('CF001');
      await tester.pump();
      verifyNever(() => bloc.add(any(that: isA<ProductBarcodeLookupRequested>())));
    });

    testWidgets('เครื่องยิงบาร์โค้ด (พิมพ์เลขแล้วกด Enter) → สั่งหาเหมือนสแกนด้วยกล้อง', (tester) async {
      final bloc = await pumpForm(tester, const []);
      await tester.enterText(find.widgetWithText(AppTextField, 'product.code'.tr), code);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      final event = verify(() => bloc.add(captureAny())).captured.last as ProductBarcodeLookupRequested;
      expect(event.code, code);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_form_dialog.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';

class MockProductBloc extends MockBloc<ProductEvent, ProductState> implements ProductBloc {}

void main() {
  const material = ProductFieldModel(id: 'f1', name: 'วัสดุ', type: ProductFieldModel.text);

  setUpAll(() async {
    await AppLang.load('th');
  });

  Future<void> pumpForm(WidgetTester tester, List<String> order) async {
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
            child: ProductFormDialog(
              product: const ProductModel(name: ''),
              fields: const [material],
              categories: const [],
              order: order,
            ),
          ),
        ),
      ),
    );
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
}

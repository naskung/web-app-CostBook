import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/settings/pages/product_form_layout_page.dart';
import 'package:costbook/features/settings/widgets/form_layout_card.dart';
import 'package:costbook/features/settings/widgets/product_field_dialog.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

void main() {
  late MockSettingsBloc bloc;
  const material = ProductFieldModel(
    id: 'f1',
    name: 'วัสดุ',
    type: ProductFieldModel.select,
    options: ['PLA', 'PETG'],
    showInList: true,
  );
  const brand = ProductFieldModel(id: 'f2', name: 'ยี่ห้อ', type: ProductFieldModel.text);
  const layout = ['image', 'name', 'code_category', 'unit', 'prices', 'sale_stock', 'description', 'f1', 'f2'];
  const loaded = SettingsState(status: AppStatus.success, fields: [material, brand], formLayout: layout);

  setUpAll(() async {
    await AppLang.load('th');
    registerFallbackValue(SettingsRequested());
  });

  setUp(() {
    bloc = MockSettingsBloc();
    when(() => bloc.state).thenReturn(loaded);
  });

  Future<void> pumpPage(WidgetTester tester, {Size size = const Size(900, 2400)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: BlocProvider<SettingsBloc>.value(value: bloc, child: const ProductFormLayoutPage())),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> cardOrder(WidgetTester tester) {
    return tester.widgetList<FormLayoutCard>(find.byType(FormLayoutCard)).map((card) => card.blockKey).toList();
  }

  testWidgets('แสดงทุกช่องของฟอร์ม (ช่องหลัก + ช่องที่ร้านเพิ่ม) เรียงตามที่บันทึก เหมือนฟอร์มจริง', (tester) async {
    await pumpPage(tester);
    expect(cardOrder(tester), layout);
    expect(find.text('product.name'.tr), findsOneWidget);
    expect(find.text('product.cost_price'.tr), findsOneWidget);
    expect(find.text('วัสดุ'), findsOneWidget);
    expect(find.text('PLA / PETG'), findsOneWidget);
    expect(find.text('settings.form_block_badge'.tr), findsNWidgets(7));
    expect(find.text('settings.form_field_badge'.tr), findsNWidgets(2));
  });

  testWidgets('ช่องหลักย้ายได้แต่แก้ / ลบไม่ได้ / ช่องที่ร้านเพิ่มมีปุ่มแก้ + ลบ', (tester) async {
    await pumpPage(tester);
    expect(find.byIcon(Icons.drag_indicator), findsNWidgets(9));
    expect(find.byTooltip('common.edit'.tr), findsNWidgets(2));
    expect(find.byTooltip('common.delete'.tr), findsNWidgets(2));
  });

  testWidgets('ลากช่อง "วัสดุ" ขึ้นไปไว้ใต้ชื่อสินค้า → โชว์ทันที + บันทึกลำดับใหม่', (tester) async {
    await pumpPage(tester);
    final handle = find.descendant(
      of: find.widgetWithText(FormLayoutCard, 'วัสดุ'),
      matching: find.byIcon(Icons.drag_indicator),
    );
    final target = tester.getCenter(
      find.descendant(
        of: find.widgetWithText(FormLayoutCard, 'product.code'.tr),
        matching: find.byIcon(Icons.drag_indicator),
      ),
    );
    final start = tester.getCenter(handle);
    final distance = target.dy - start.dy - 20;
    final gesture = await tester.startGesture(start);
    await tester.pump();
    for (var step = 0; step < 20; step++) {
      await gesture.moveBy(Offset(0, distance / 20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    const expected = ['image', 'name', 'f1', 'code_category', 'unit', 'prices', 'sale_stock', 'description', 'f2'];
    expect(cardOrder(tester), expected);
    final event =
        verify(() => bloc.add(captureAny(that: isA<ProductFormLayoutSaved>()))).captured.last as ProductFormLayoutSaved;
    expect(event.keys, expected);
  });

  testWidgets('กดแก้ช่องที่ร้านเพิ่ม เปิดหน้าต่างแก้ช่องนั้น', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byTooltip('common.edit'.tr).first);
    await tester.pumpAndSettle();
    expect(find.byType(ProductFieldDialog), findsOneWidget);
  });

  testWidgets('มือถือ 375 แสดงได้ไม่ล้นจอ', (tester) async {
    await pumpPage(tester, size: const Size(375, 2600));
    expect(tester.takeException(), isNull);
    expect(cardOrder(tester), layout);
  });
}

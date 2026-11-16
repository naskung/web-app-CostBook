import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/features/cost/widgets/cost_item_dialog.dart';
import 'package:costbook/features/product/models/product_model.dart';

void main() {
  const pla = ProductModel(id: 'm1', name: 'เส้น PLA', unit: 'กรัม', costPrice: 0.45, stock: 1000, forSale: false);
  const labor = CostPresetModel(id: 'pr1', type: CostItemModel.labor, name: 'ค่าแรงขัดงาน', unit: 'นาที', unitPrice: 1);
  const power = CostPresetModel(id: 'pr2', type: CostItemModel.overhead, name: 'ค่าไฟ', unit: 'ชม.', unitPrice: 0.68);
  const oldMaterial = CostPresetModel(id: 'pr3', type: CostItemModel.material, name: 'สีสเปรย์', unitPrice: 5);

  setUpAll(() async {
    await AppLang.load('th');
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    required String type,
    List<ProductModel> materials = const [pla],
    bool forPreset = false,
    String name = '',
  }) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CostItemDialog(
            item: CostItemModel(type: type, name: name),
            presets: const [labor, power, oldMaterial],
            materials: materials,
            forPreset: forPreset,
          ),
        ),
      ),
    );
  }

  testWidgets('เพิ่มวัตถุดิบ: มีช่องเลือกวัสดุจากสต็อก ไม่มีช่องค่าใช้จ่ายเพิ่มเติม ไม่มีติ๊กบันทึก', (tester) async {
    await pumpDialog(tester, type: CostItemModel.material);
    expect(find.text('cost.material'.tr), findsOneWidget);
    expect(find.text('cost.from_preset'.tr), findsNothing);
    expect(find.text('cost.remember'.tr), findsNothing);
  });

  testWidgets('เลือกวัสดุจากสต็อก ชื่อ / หน่วย / ราคา มาจากสต็อก', (tester) async {
    await pumpDialog(tester, type: CostItemModel.material);
    await tester.tap(find.text('cost.no_material'.tr));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('เส้น PLA (').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'เส้น PLA'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'กรัม'), findsOneWidget);
    expect(find.text('cost.material_hint'.tr), findsOneWidget);
  });

  testWidgets('ยังไม่มีวัสดุในสต็อก: บอกให้ไปเพิ่มที่หน้าสินค้า แท็บวัสดุ', (tester) async {
    await pumpDialog(tester, type: CostItemModel.material, materials: const []);
    expect(find.text('cost.no_materials_hint'.tr), findsOneWidget);
    expect(find.text('cost.material'.tr), findsNothing);
  });

  testWidgets('เพิ่มค่าแรง: เลือกจากค่าใช้จ่ายเพิ่มเติมได้เฉพาะค่าแรง ไม่มีช่องสต็อก มีติ๊กบันทึก', (tester) async {
    await pumpDialog(tester, type: CostItemModel.labor);
    expect(find.text('cost.material'.tr), findsNothing);
    expect(find.text('cost.remember'.tr), findsOneWidget);
    await tester.tap(find.text('cost.choose_preset'.tr));
    await tester.pumpAndSettle();
    expect(find.text('ค่าแรงขัดงาน'), findsWidgets);
    expect(find.text('ค่าไฟ'), findsNothing);
    expect(find.text('สีสเปรย์'), findsNothing);
  });

  testWidgets('ตั้งค่าใช้จ่ายเพิ่มเติมใหม่: เลือกประเภทวัตถุดิบไม่ได้ (วัตถุดิบอยู่ในสต็อก)', (tester) async {
    await pumpDialog(tester, type: CostItemModel.labor, forPreset: true);
    await tester.tap(find.text('cost.type.labor'.tr));
    await tester.pumpAndSettle();
    expect(find.text('cost.type.overhead'.tr), findsWidgets);
    expect(find.text('cost.type.material'.tr), findsNothing);
  });

  testWidgets('แก้ค่าใช้จ่ายเพิ่มเติมเดิมที่เป็นวัตถุดิบ ยังแก้ได้ (ไม่หาย)', (tester) async {
    await pumpDialog(tester, type: CostItemModel.material, forPreset: true, name: 'สีสเปรย์');
    expect(find.text('cost.type.material'.tr), findsOneWidget);
    expect(find.text('cost.material'.tr), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';
import 'package:costbook/features/stock/widgets/stock_movement_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';

class MockStockRepository extends Mock implements StockRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockStockRepository repository;

  const keychain = StockItemModel(productId: 'p1', name: 'พวงกุญแจ', unit: 'ชิ้น', stock: 8);

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    repository = MockStockRepository();
    when(() => repository.getStock()).thenAnswer((_) async => [keychain]);
    when(
      () => repository.addMovement(
        type: any(named: 'type'),
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
        note: any(named: 'note'),
        unitCost: any(named: 'unitCost'),
        supplier: any(named: 'supplier'),
        skipMaterials: any(named: 'skipMaterials'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> openDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) => StockBloc(repository, withHistory: false)..add(StockRequested()),
          child: Builder(
            builder:
                (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => StockMovementDialog.show(context, productId: 'p1'),
                    child: const Text('open'),
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(String labelKey) {
    return find.descendant(of: find.widgetWithText(AppTextField, labelKey.tr), matching: find.byType(TextFormField));
  }

  Finder tab(String labelKey) => find.descendant(of: find.byType(Dialog), matching: find.text(labelKey.tr)).first;

  testWidgets('เปิดมาที่แท็บรับเข้า มีช่องราคาทุน / ตัดวัสดุ และเลือกสินค้าของแถวนั้นไว้ให้แล้ว', (tester) async {
    await openDialog(tester);
    expect(find.text('stock.stock_in_title'.tr), findsOneWidget);
    expect(find.text('stock.current'.trParams({'stock': '8', 'unit': 'ชิ้น'})), findsOneWidget);
    expect(field('stock.unit_cost'), findsOneWidget);
    expect(find.text('stock.use_materials'.tr), findsOneWidget);
  });

  testWidgets('กดแท็บเบิกออก ช่องของรับเข้าหายไป จำนวนที่กรอกไว้ยังอยู่ กดเบิกออกแล้วส่งเป็นเบิกออก', (tester) async {
    await openDialog(tester);
    await tester.enterText(field('common.quantity'), '3');
    await tester.tap(tab('stock.stock_out'));
    await tester.pumpAndSettle();

    expect(find.text('stock.stock_out_title'.tr), findsOneWidget);
    expect(field('stock.unit_cost'), findsNothing);
    expect(find.text('stock.use_materials'.tr), findsNothing);
    expect(tester.widget<TextFormField>(field('common.quantity')).controller?.text, '3');

    await tester.tap(find.widgetWithText(ElevatedButton, 'stock.stock_out'.tr));
    await tester.pumpAndSettle();
    verify(
      () => repository.addMovement(
        type: MovementModel.stockOut,
        productId: 'p1',
        quantity: 3,
        note: '',
        unitCost: 0,
        supplier: '',
        skipMaterials: false,
      ),
    ).called(1);
    expect(find.byType(Dialog), findsNothing);
  });
}

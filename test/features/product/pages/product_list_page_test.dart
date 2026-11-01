import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/category/repository/category_repository.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/pages/product_list_page.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockStockRepository extends Mock implements StockRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProductRepository productRepository;
  late MockCategoryRepository categoryRepository;
  late MockStockRepository stockRepository;

  const keychain = ProductModel(id: 'p1', name: 'พวงกุญแจ', unit: 'ชิ้น', costPrice: 20, sellPrice: 59, stock: 8);
  const service = ProductModel(id: 'p2', name: 'ค่าออกแบบ', sellPrice: 300, trackStock: false);
  const pla = ProductModel(id: 'p3', name: 'เส้น PLA', unit: 'กรัม', costPrice: 0.45, minStock: 250, forSale: false);

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    productRepository = MockProductRepository();
    categoryRepository = MockCategoryRepository();
    stockRepository = MockStockRepository();
    when(() => productRepository.getProducts()).thenAnswer((_) async => [keychain, service, pla]);
    when(() => categoryRepository.getCategories()).thenAnswer((_) async => []);
    when(() => stockRepository.getStock()).thenAnswer(
      (_) async => const [
        StockItemModel(productId: 'p1', name: 'พวงกุญแจ', unit: 'ชิ้น', stock: 8),
        StockItemModel(productId: 'p3', name: 'เส้น PLA', unit: 'กรัม'),
      ],
    );
  });

  Future<void> pumpPage(WidgetTester tester, {Size size = const Size(1180, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ProductBloc(productRepository, categoryRepository)..add(ProductsRequested())),
              BlocProvider(create: (_) => StockBloc(stockRepository, withHistory: false)..add(StockRequested())),
              BlocProvider(create: (_) => SettingsBloc(MockSettingsRepository())),
            ],
            child: const ProductListPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ท้ายแถวเหลือ 2 ปุ่ม: รับเข้า / เบิกออก (เฉพาะสินค้าที่นับสต็อก) + เมนู ⋮', (tester) async {
    await pumpPage(tester);
    expect(find.byTooltip('stock.move'.tr), findsNWidgets(2));
    expect(find.byIcon(Icons.more_vert), findsNWidgets(3));
    expect(find.byTooltip('common.edit'.tr), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('กดเมนู ⋮ เห็น เช็คราคาตลาด / แก้ไข / ลบ — กดลบแล้วถามยืนยัน', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    expect(find.text('market.check_tooltip'.tr), findsOneWidget);
    expect(find.text('common.edit'.tr), findsOneWidget);
    await tester.tap(find.text('common.delete'.tr));
    await tester.pumpAndSettle();
    expect(find.text('product.delete_title'.tr), findsOneWidget);
  });

  testWidgets('กดปุ่มรับเข้า / เบิกออกของแถว เปิดหน้าต่างแบบแท็บ เลือกสินค้าแถวนั้นไว้ให้', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byTooltip('stock.move'.tr).first);
    await tester.pumpAndSettle();
    final dialog = find.byType(Dialog);
    expect(find.descendant(of: dialog, matching: find.text('stock.stock_in'.tr)), findsWidgets);
    expect(find.descendant(of: dialog, matching: find.text('stock.stock_out'.tr)), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('พวงกุญแจ')), findsOneWidget);
  });

  testWidgets('วัสดุ: ป้าย "วัสดุ" อยู่บรรทัดใต้ชื่อ คู่กับหน่วย (ไม่ต่อท้ายชื่อ)', (tester) async {
    await pumpPage(tester);
    final name = tester.getRect(find.text('เส้น PLA'));
    final badge = tester.getRect(
      find.descendant(of: find.byType(AppBadge), matching: find.text('product.kind_material'.tr)).first,
    );
    final unit = tester.getRect(find.text('กรัม').first);
    expect(badge.top, greaterThanOrEqualTo(name.bottom));
    expect(badge.center.dy, closeTo(unit.center.dy, 2));
    expect(unit.left, greaterThan(badge.right));
  });

  testWidgets('จอแคบ ตารางเลื่อนซ้าย-ขวาได้ ไม่ล้น', (tester) async {
    await pumpPage(tester, size: const Size(800, 900));
    expect(tester.takeException(), isNull);
    expect(
      find.byWidgetPredicate((widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal),
      findsWidgets,
    );
  });
}

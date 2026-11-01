import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';
import 'package:costbook/features/dashboard/repository/dashboard_repository.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/repository/ai_repository.dart';
import 'package:costbook/features/market/repository/market_repository.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockAiRepository extends Mock implements AiRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockStockRepository extends Mock implements StockRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDashboardRepository repository;

  setUpAll(() async {
    await AppLang.load('th');
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = MockDashboardRepository();
  });

  Future<void> pumpDashboard(WidgetTester tester, Size screenSize) async {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SettingsBloc(MockSettingsRepository())),
              BlocProvider(
                create:
                    (_) => AssistantBloc(
                      aiRepository: MockAiRepository(),
                      productRepository: MockProductRepository(),
                      stockRepository: MockStockRepository(),
                      transactionRepository: MockTransactionRepository(),
                      marketRepository: MockMarketRepository(),
                    ),
              ),
              BlocProvider(
                create: (_) => DashboardBloc(repository, month: DateTime(2026, 10))..add(DashboardRequested()),
              ),
            ],
            child: const DashboardPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const dashboard = DashboardModel(
    income: 12500,
    expense: 4300.5,
    revenue: 12500,
    operatingExpense: 4300.5,
    profit: 8199.5,
    invoiceCount: 8,
    lowStockCount: 1,
    lowStock: [LowStockItemModel(productId: 'p1', name: 'กาแฟเย็น', unit: 'แก้ว', stock: 2, minStock: 5)],
  );

  final screenSizes = {
    'มือถือ 375x667': const Size(375, 667),
    'แท็บเล็ต 768x1024': const Size(768, 1024),
    'จอคอม 1280x800': const Size(1280, 800),
  };

  screenSizes.forEach((name, size) {
    testWidgets('$name แสดงตัวเลขสรุปและสินค้าใกล้หมดได้ไม่ล้นจอ', (tester) async {
      when(() => repository.getDashboard(any())).thenAnswer((_) async => dashboard);
      await pumpDashboard(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('8,199.50'), findsOneWidget);
      expect(find.text('4,300.50'), findsOneWidget);
      expect(find.text('กาแฟเย็น'), findsOneWidget);
      expect(find.text('ตุลาคม 2569'), findsOneWidget);
    });
  });

  // ร้านที่มีข้อมูลเต็มทุกกล่อง: ขายดี 5 / รายจ่าย 8 หมวด / เทียบราคา 5 / ใกล้หมด 5 — จอคอมแต่ละแถวสูงเท่ากัน ต้องไม่ล้นกล่อง
  final fullDashboard = DashboardModel(
    revenue: 52000,
    profit: 9800,
    operatingExpense: 7200,
    invoiceCount: 120,
    lowStockCount: 5,
    lowStock: [
      for (var i = 0; i < 5; i++)
        LowStockItemModel(productId: 'l$i', name: 'สินค้าใกล้หมด $i', unit: 'ชิ้น', stock: i, minStock: 10),
    ],
    topProducts: [
      for (var i = 0; i < 5; i++)
        ProductSalesModel(
          productId: 'p$i',
          name: 'สินค้าขายดีอันดับ $i',
          unit: 'ชิ้น',
          quantity: 40 - i,
          netSales: 9000.0 - i * 900,
          margin: 32.5,
        ),
    ],
    expenseByCategory: [
      for (final category in ['rent', 'salary', 'utilities', 'shipping', 'marketing', 'equipment', 'tax', 'other'])
        CategoryAmountModel(category: category, amount: 900, percent: 12.5),
    ],
    market: [
      for (var i = 0; i < 5; i++)
        MarketPositionModel(
          productId: 'm$i',
          name: 'สินค้าเทียบราคา $i',
          customerPrice: 120,
          retailLow: 90,
          retailHigh: 150,
          retailTypical: 120,
          position: 'within',
        ),
    ],
  );

  screenSizes.forEach((name, size) {
    testWidgets('$name ร้านที่มีข้อมูลเต็มทุกกล่อง แสดงได้ไม่ล้นกล่อง', (tester) async {
      when(() => repository.getDashboard(any())).thenAnswer((_) async => fullDashboard);
      await pumpDashboard(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('9,800.00'), findsOneWidget);
    });
  });

  testWidgets('โหลดไม่สำเร็จ แสดงข้อความ error และปุ่มลองใหม่', (tester) async {
    when(() => repository.getDashboard(any())).thenThrow(ApiException('network_error'));
    await pumpDashboard(tester, const Size(1280, 800));
    expect(find.text('error.network_error'.tr), findsOneWidget);
    expect(find.text('common.retry'.tr), findsOneWidget);
  });

  testWidgets('กดเดือนถัดไป โหลดข้อมูลเดือนพฤศจิกายน', (tester) async {
    when(() => repository.getDashboard(any())).thenAnswer((_) async => dashboard);
    await pumpDashboard(tester, const Size(1280, 800));
    await tester.tap(find.byTooltip('common.next_month'.tr));
    await tester.pumpAndSettle();
    expect(find.text('พฤศจิกายน 2569'), findsOneWidget);
    verify(() => repository.getDashboard(DateTime(2026, 11))).called(1);
  });
}

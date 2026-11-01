import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/pages/stock_page.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';

class MockStockRepository extends Mock implements StockRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockStockRepository repository;

  final sold = MovementModel(
    id: 'm1',
    productId: 'p1',
    productName: 'เคสมือถือ',
    unit: 'ชิ้น',
    type: MovementModel.stockOut,
    quantity: 1,
    invoiceNo: 'RC-2026-0004',
    createdAt: DateTime(2026, 11, 1, 10),
    hasProfit: true,
    saleAmount: 84.97,
    costAmount: 53.2,
    profit: 31.77,
  );
  final soldAtLoss = MovementModel(
    id: 'm2',
    productId: 'p2',
    productName: 'พวงกุญแจ',
    unit: 'ชิ้น',
    type: MovementModel.stockOut,
    quantity: 2,
    invoiceNo: 'RC-2026-0004',
    createdAt: DateTime(2026, 11, 1, 10),
    hasProfit: true,
    saleAmount: 215.03,
    costAmount: 227.74,
    profit: -12.71,
  );
  final received = MovementModel(
    id: 'm3',
    productId: 'p1',
    productName: 'เคสมือถือ',
    type: MovementModel.stockIn,
    quantity: 10,
    createdAt: DateTime(2026, 11, 1, 9),
  );

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    repository = MockStockRepository();
    when(() => repository.getStock()).thenAnswer((_) async => []);
    when(() => repository.getMovements()).thenAnswer((_) async => [sold, soldAtLoss, received]);
  });

  Future<void> pumpPage(WidgetTester tester, {Size size = const Size(1280, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BlocProvider(create: (_) => StockBloc(repository)..add(StockRequested()), child: const StockPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('แถวที่ขาย: ป้าย "ขาย" + กำไร + ยอดขาย · ทุน / ขาดทุนเป็นเลขติดลบ / แถวรับเข้าไม่มีกำไร', (tester) async {
    await pumpPage(tester);
    expect(find.text('stock.sold'.tr), findsNWidgets(2));
    expect(find.text('+31.77'), findsOneWidget);
    expect(find.text('stock.profit_detail'.trParams({'sale': '84.97', 'cost': '53.20'})), findsOneWidget);
    expect(find.text('-12.71'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('มือถือ 375 แสดงเป็นการ์ด มีกำไรไม่ล้นจอ', (tester) async {
    await pumpPage(tester, size: const Size(375, 800));
    expect(find.text('+31.77'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

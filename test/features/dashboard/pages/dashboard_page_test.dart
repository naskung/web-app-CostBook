import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';
import 'package:costbook/features/dashboard/repository/dashboard_repository.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

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
          body: BlocProvider(
            create: (_) => DashboardBloc(repository, month: DateTime(2026, 10))..add(DashboardRequested()),
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
      expect(find.text('12,500.00'), findsOneWidget);
      expect(find.text('กาแฟเย็น'), findsOneWidget);
      expect(find.text('ตุลาคม 2569'), findsOneWidget);
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

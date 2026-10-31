import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/routes/app_shell.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';
import 'package:costbook/features/product/pages/product_list_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository repository;

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.logout()).thenAnswer((_) async {});
  });

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: AppRoutes.dashboard,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Text('login-page'),
        ),
        ShellRoute(
          builder: (context, state, child) => BlocProvider(
            create: (_) => AuthBloc(repository),
            child: AppShell(currentPath: state.uri.path, child: child),
          ),
          routes: [
            GoRoute(path: AppRoutes.dashboard, builder: (context, state) => const DashboardPage()),
            GoRoute(path: AppRoutes.products, builder: (context, state) => const ProductListPage()),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
  }

  testWidgets('เปิดหน้าแรก หัวข้อด้านบนเป็นชื่อเมนูภาพรวม', (tester) async {
    await pumpShell(tester);
    expect(find.widgetWithText(AppBar, 'menu.dashboard'.tr), findsOneWidget);
    expect(find.text('dashboard.welcome'.tr), findsOneWidget);
  });

  testWidgets('กดเมนูสินค้า ไปหน้าสินค้า และหัวข้อเปลี่ยนตาม', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('menu.products'.tr));
    await tester.pumpAndSettle();
    expect(find.text('product.description'.tr), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'menu.products'.tr), findsOneWidget);
  });

  testWidgets('กดออกจากระบบ เรียก logout แล้วกลับไปหน้า login', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('common.logout'.tr));
    await tester.pumpAndSettle();
    verify(() => repository.logout()).called(1);
    expect(find.text('login-page'), findsOneWidget);
  });
}

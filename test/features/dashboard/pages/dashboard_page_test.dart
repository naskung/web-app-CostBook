import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';

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

  Future<void> pumpDashboardPage(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.dashboard,
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => BlocProvider(
            create: (_) => AuthBloc(repository),
            child: const DashboardPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Text('login-page'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
  }

  testWidgets('แสดงข้อความต้อนรับ และปุ่มออกจากระบบ', (tester) async {
    await pumpDashboardPage(tester);
    expect(find.text('dashboard.welcome'.tr), findsOneWidget);
    expect(find.text('common.logout'.tr), findsOneWidget);
  });

  testWidgets('กดออกจากระบบ เรียก logout แล้วกลับไปหน้า login', (tester) async {
    await pumpDashboardPage(tester);
    await tester.tap(find.text('common.logout'.tr));
    await tester.pumpAndSettle();
    verify(() => repository.logout()).called(1);
    expect(find.text('login-page'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/routes/app_shell.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/assistant/repository/ai_repository.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/market/repository/market_repository.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';
import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/repository/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockAiRepository extends Mock implements AiRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockStockRepository extends Mock implements StockRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockMarketRepository extends Mock implements MarketRepository {}

class MockUserRepository extends Mock implements UserRepository {}

AssistantBloc _assistantBloc(AiStatusModel aiStatus) {
  final aiRepository = MockAiRepository();
  when(() => aiRepository.getStatus()).thenAnswer((_) async => aiStatus);
  return AssistantBloc(
    aiRepository: aiRepository,
    productRepository: MockProductRepository(),
    stockRepository: MockStockRepository(),
    transactionRepository: MockTransactionRepository(),
    marketRepository: MockMarketRepository(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository repository;
  late MockSettingsRepository settingsRepository;
  late MockUserRepository userRepository;

  setUpAll(() async {
    await AppLang.load('th');
  });

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.logout()).thenAnswer((_) async {});
    settingsRepository = MockSettingsRepository();
    when(() => settingsRepository.getCompany()).thenAnswer((_) async => const CompanyModel(name: 'ร้าน'));
    when(() => settingsRepository.getFields()).thenAnswer((_) async => []);
    userRepository = MockUserRepository();
    when(
      () => userRepository.getMe(),
    ).thenAnswer((_) async => const UserModel(id: 'u1', email: 'a@b.co', firstName: 'สมชาย', role: UserRole.manager));
  });

  Future<void> pumpShell(
    WidgetTester tester, {
    AiStatusModel aiStatus = const AiStatusModel(enabled: true, provider: 'gemini'),
    Size size = const Size(1440, 900),
    String initialLocation = AppRoutes.dashboard,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: AppRoutes.login, builder: (context, state) => const Text('login-page')),
        ShellRoute(
          builder:
              (context, state, child) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => AuthBloc(repository)),
                  BlocProvider(create: (_) => SettingsBloc(settingsRepository)..add(SettingsRequested())),
                  BlocProvider(create: (_) => _assistantBloc(aiStatus)..add(AssistantOpened())),
                  BlocProvider(create: (_) => ProfileBloc(userRepository)..add(ProfileRequested())),
                ],
                child: AppShell(currentPath: state.uri.path, child: child),
              ),
          routes: [
            GoRoute(path: AppRoutes.dashboard, builder: (context, state) => const Text('dashboard-page')),
            GoRoute(path: AppRoutes.products, builder: (context, state) => const Text('products-page')),
            GoRoute(path: AppRoutes.profile, builder: (context, state) => const Text('profile-page')),
            GoRoute(path: AppRoutes.sell, builder: (context, state) => const Text('sell-page')),
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
    expect(find.text('dashboard-page'), findsOneWidget);
  });

  testWidgets('กางกลุ่มสินค้า กดรายการสินค้า ไปหน้าสินค้า และหัวข้อเป็นชื่อเมนูย่อย', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('menu.products'.tr));
    await tester.pumpAndSettle();
    await tester.tap(find.text('menu.product_list'.tr));
    await tester.pumpAndSettle();
    expect(find.text('products-page'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'menu.product_list'.tr), findsOneWidget);
  });

  testWidgets('กดออกจากระบบ เรียก logout แล้วกลับไปหน้า login', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('common.logout'.tr));
    await tester.pumpAndSettle();
    verify(() => repository.logout()).called(1);
    expect(find.text('login-page'), findsOneWidget);
  });

  testWidgets('ร้านปิดหน้าคำนวณต้นทุน ไม่เห็นเมนูคำนวณต้นทุน', (tester) async {
    when(
      () => settingsRepository.getCompany(),
    ).thenAnswer((_) async => const CompanyModel(name: 'ร้านของชำ', useCostPage: false));
    await pumpShell(tester);
    await tester.pumpAndSettle();
    expect(find.text('menu.cost'.tr), findsNothing);
    expect(find.text('menu.sell'.tr), findsOneWidget);
  });

  testWidgets('AI ฟรีที่ค้นเว็บได้ (API มีตัวค้นเว็บฟรี) หัวแชทบอกว่าค้นเว็บได้', (tester) async {
    await pumpShell(tester, aiStatus: const AiStatusModel(enabled: true, provider: 'gemini', webSearch: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('assistant.open'.tr));
    await tester.pumpAndSettle();
    expect(find.text('assistant.provider_free_search'.tr), findsOneWidget);
    expect(find.text('assistant.provider_free'.tr), findsNothing);
  });

  testWidgets('ทุกหน้ามีปุ่มแชท AI มุมขวาล่าง กดแล้วเปิดหน้าต่างแชท กดย่อแล้วปิด', (tester) async {
    await pumpShell(tester);
    await tester.pumpAndSettle();
    expect(find.byTooltip('assistant.open'.tr), findsOneWidget);

    await tester.tap(find.byTooltip('assistant.open'.tr));
    await tester.pumpAndSettle();
    expect(find.text('assistant.welcome_title'.tr), findsOneWidget);
    expect(find.text('assistant.provider_free'.tr), findsOneWidget);

    await tester.tap(find.byTooltip('assistant.minimize'.tr));
    await tester.pumpAndSettle();
    expect(find.text('assistant.welcome_title'.tr), findsNothing);
    expect(find.byTooltip('assistant.open'.tr), findsOneWidget);
  });

  testWidgets('เมนูข้างมีชื่อ + ตำแหน่งของผู้ใช้ที่ login อยู่ กดแล้วไปหน้าโปรไฟล์ หัวข้อเป็นโปรไฟล์', (tester) async {
    await pumpShell(tester);
    await tester.pumpAndSettle();
    expect(find.text('สมชาย'), findsOneWidget);
    expect(find.text('role.manager'.tr), findsOneWidget);

    await tester.tap(find.text('สมชาย'));
    await tester.pumpAndSettle();
    expect(find.text('profile-page'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'menu.profile'.tr), findsOneWidget);
  });

  double chatButtonBottom(WidgetTester tester) {
    return tester.view.physicalSize.height - tester.getRect(find.byTooltip('assistant.open'.tr)).bottom;
  }

  testWidgets('หน้าขายบนมือถือ ปุ่มแชทยกขึ้นไปอยู่เหนือแถบยอดรวม / หน้าอื่นอยู่มุมล่างเหมือนเดิม', (tester) async {
    await pumpShell(tester, size: const Size(375, 800), initialLocation: AppRoutes.sell);
    await tester.pumpAndSettle();
    expect(chatButtonBottom(tester), greaterThanOrEqualTo(AppSizes.sellCartBarHeight));

    await pumpShell(tester, size: const Size(375, 800), initialLocation: AppRoutes.products);
    await tester.pumpAndSettle();
    expect(chatButtonBottom(tester), lessThan(AppSizes.sellCartBarHeight));
  });

  testWidgets('หน้าขายบนจอคอม ปุ่มแชทอยู่มุมล่างเหมือนเดิม (ใต้บิล)', (tester) async {
    await pumpShell(tester, initialLocation: AppRoutes.sell);
    await tester.pumpAndSettle();
    expect(chatButtonBottom(tester), lessThan(AppSizes.sellCartBarHeight));
  });
}

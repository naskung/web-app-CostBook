import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/routes/app_page_transition.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/routes/app_shell.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/pages/assistant_page.dart';
import 'package:costbook/features/assistant/repository/ai_repository.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/pages/login_page.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';
import 'package:costbook/features/cost/bloc/cost_bloc.dart';
import 'package:costbook/features/cost/pages/cost_page.dart';
import 'package:costbook/features/cost/repository/cost_repository.dart';
import 'package:costbook/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';
import 'package:costbook/features/dashboard/repository/dashboard_repository.dart';
import 'package:costbook/features/invoice/bloc/invoice_detail_bloc.dart';
import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/bloc/invoice_list_bloc.dart';
import 'package:costbook/features/invoice/pages/invoice_detail_page.dart';
import 'package:costbook/features/invoice/pages/invoice_form_page.dart';
import 'package:costbook/features/invoice/pages/invoice_list_page.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';
import 'package:costbook/features/market/bloc/market_bloc.dart';
import 'package:costbook/features/market/pages/market_page.dart';
import 'package:costbook/features/market/repository/market_repository.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/pages/product_list_page.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/pages/settings_page.dart';
import 'package:costbook/features/sell/pages/sell_page.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/pages/stock_page.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';
import 'package:costbook/features/transaction/bloc/transaction_bloc.dart';
import 'package:costbook/features/transaction/pages/transaction_list_page.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  redirect: _redirect,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      pageBuilder:
          (context, state) => AppPageTransition.backward(
            key: state.pageKey,
            child: BlocProvider(create: _createAuthBloc, child: const LoginPage()),
          ),
    ),
    ShellRoute(
      pageBuilder:
          (context, state, child) => AppPageTransition.forward(
            key: state.pageKey,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: _createAuthBloc),
                BlocProvider(create: (_) => SettingsBloc(SettingsRepository(ApiClient()))..add(SettingsRequested())),
                BlocProvider(create: _createAssistantBloc),
              ],
              child: AppShell(currentPath: state.uri.path, child: child),
            ),
          ),
      routes: [
        _menuRoute(AppRoutes.dashboard, _dashboardPage),
        _menuRoute(AppRoutes.sell, _sellPage),
        _menuRoute(AppRoutes.products, _productPage),
        _menuRoute(AppRoutes.market, _marketPage),
        _menuRoute(AppRoutes.cost, _costPage),
        _menuRoute(AppRoutes.stock, _stockPage),
        _menuRoute(AppRoutes.transactions, _transactionPage),
        _menuRoute(AppRoutes.invoices, _invoiceListPage),
        _menuRoute(AppRoutes.invoiceCreate, _invoiceFormPage),
        _menuRoute(AppRoutes.invoiceDetail, _invoiceDetailPage),
        _menuRoute(AppRoutes.assistant, _assistantPage),
        _menuRoute(AppRoutes.settings, _settingsPage),
      ],
    ),
  ],
);

GoRoute _menuRoute(String path, Widget Function(GoRouterState state) buildPage) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => AppPageTransition.forward(key: state.pageKey, child: buildPage(state)),
  );
}

AuthBloc _createAuthBloc(BuildContext context) {
  return AuthBloc(AuthRepository(ApiClient()));
}

AssistantBloc _createAssistantBloc(BuildContext context) {
  return AssistantBloc(
    aiRepository: AiRepository(ApiClient()),
    productRepository: ProductRepository(ApiClient()),
    stockRepository: StockRepository(ApiClient()),
    transactionRepository: TransactionRepository(ApiClient()),
    marketRepository: MarketRepository(ApiClient()),
  );
}

DateTime _thisMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
}

Widget _dashboardPage(GoRouterState state) {
  return BlocProvider(
    create: (_) => DashboardBloc(DashboardRepository(ApiClient()), month: _thisMonth())..add(DashboardRequested()),
    child: const DashboardPage(),
  );
}

Widget _productPage(GoRouterState state) {
  return BlocProvider(
    create: (_) => ProductBloc(ProductRepository(ApiClient()))..add(ProductsRequested()),
    child: const ProductListPage(),
  );
}

Widget _marketPage(GoRouterState state) {
  final productId = state.pathParameters['id'] ?? '';
  return BlocProvider(
    create:
        (_) => MarketBloc(
          MarketRepository(ApiClient()),
          ProductRepository(ApiClient()),
          AiRepository(ApiClient()),
          productId: productId,
        )..add(MarketOpened()),
    child: const MarketPage(),
  );
}

Widget _assistantPage(GoRouterState state) {
  return const AssistantPage();
}

Widget _costPage(GoRouterState state) {
  return BlocProvider(
    create: (_) => CostBloc(CostRepository(ApiClient()), ProductRepository(ApiClient()))..add(CostPageOpened()),
    child: const CostPage(),
  );
}

Widget _stockPage(GoRouterState state) {
  return BlocProvider(
    create: (_) => StockBloc(StockRepository(ApiClient()))..add(StockRequested()),
    child: const StockPage(),
  );
}

Widget _transactionPage(GoRouterState state) {
  return BlocProvider(
    create:
        (_) => TransactionBloc(TransactionRepository(ApiClient()), month: _thisMonth())..add(TransactionsRequested()),
    child: const TransactionListPage(),
  );
}

Widget _invoiceListPage(GoRouterState state) {
  return BlocProvider(
    create: (_) => InvoiceListBloc(InvoiceRepository(ApiClient()), month: _thisMonth())..add(InvoicesRequested()),
    child: const InvoiceListPage(),
  );
}

Widget _invoiceFormPage(GoRouterState state) {
  return BlocProvider(
    create: (_) => _createInvoiceFormBloc()..add(InvoiceFormOpened()),
    child: const InvoiceFormPage(),
  );
}

Widget _invoiceDetailPage(GoRouterState state) {
  final invoiceId = state.pathParameters['id'] ?? '';
  return BlocProvider(
    create:
        (_) => InvoiceDetailBloc(InvoiceRepository(ApiClient()), invoiceId: invoiceId)..add(InvoiceDetailRequested()),
    child: const InvoiceDetailPage(),
  );
}

Widget _settingsPage(GoRouterState state) {
  return const SettingsPage();
}

Widget _sellPage(GoRouterState state) {
  return BlocProvider(create: (_) => _createInvoiceFormBloc()..add(InvoiceFormOpened()), child: const SellPage());
}

InvoiceFormBloc _createInvoiceFormBloc() {
  return InvoiceFormBloc(
    InvoiceRepository(ApiClient()),
    ProductRepository(ApiClient()),
    SettingsRepository(ApiClient()),
  );
}

String? _redirect(BuildContext context, GoRouterState state) {
  final isLoggedIn = ApiClient.token.isNotEmpty;
  final isOnLoginPage = state.matchedLocation == AppRoutes.login;
  if (!isLoggedIn && !isOnLoginPage) return AppRoutes.login;
  if (isLoggedIn && isOnLoginPage) return AppRoutes.dashboard;
  return null;
}

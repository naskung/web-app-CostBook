import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/routes/app_page_transition.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/routes/app_shell.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/pages/login_page.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';
import 'package:costbook/features/cost/pages/cost_page.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';
import 'package:costbook/features/invoice/pages/invoice_list_page.dart';
import 'package:costbook/features/product/pages/product_list_page.dart';
import 'package:costbook/features/settings/pages/settings_page.dart';
import 'package:costbook/features/stock/pages/stock_page.dart';
import 'package:costbook/features/transaction/pages/transaction_list_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  redirect: _redirect,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => AppPageTransition.backward(
        key: state.pageKey,
        child: BlocProvider(
          create: _createAuthBloc,
          child: const LoginPage(),
        ),
      ),
    ),
    ShellRoute(
      pageBuilder: (context, state, child) => AppPageTransition.forward(
        key: state.pageKey,
        child: BlocProvider(
          create: _createAuthBloc,
          child: AppShell(currentPath: state.uri.path, child: child),
        ),
      ),
      routes: [
        _menuRoute(AppRoutes.dashboard, const DashboardPage()),
        _menuRoute(AppRoutes.products, const ProductListPage()),
        _menuRoute(AppRoutes.cost, const CostPage()),
        _menuRoute(AppRoutes.stock, const StockPage()),
        _menuRoute(AppRoutes.transactions, const TransactionListPage()),
        _menuRoute(AppRoutes.invoices, const InvoiceListPage()),
        _menuRoute(AppRoutes.settings, const SettingsPage()),
      ],
    ),
  ],
);

GoRoute _menuRoute(String path, Widget page) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => AppPageTransition.forward(key: state.pageKey, child: page),
  );
}

AuthBloc _createAuthBloc(BuildContext context) {
  return AuthBloc(AuthRepository(ApiClient()));
}

String? _redirect(BuildContext context, GoRouterState state) {
  final isLoggedIn = ApiClient.token.isNotEmpty;
  final isOnLoginPage = state.matchedLocation == AppRoutes.login;
  if (!isLoggedIn && !isOnLoginPage) return AppRoutes.login;
  if (isLoggedIn && isOnLoginPage) return AppRoutes.dashboard;
  return null;
}

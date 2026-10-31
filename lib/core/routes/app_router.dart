import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/pages/login_page.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';
import 'package:costbook/features/dashboard/pages/dashboard_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  redirect: _redirect,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => BlocProvider(
        create: _createAuthBloc,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => BlocProvider(
        create: _createAuthBloc,
        child: const DashboardPage(),
      ),
    ),
  ],
);

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

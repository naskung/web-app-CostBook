import 'package:flutter/material.dart';

import 'package:costbook/app.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/lang/language_bloc.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/routes/app_router.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLang.load(await LanguageBloc.savedCode());
  await AuthRepository(ApiClient()).loadSavedToken();
  ApiClient.onUnauthorized = _goToLoginWhenTokenExpired;
  runApp(const App());
}

Future<void> _goToLoginWhenTokenExpired() async {
  await AuthRepository(ApiClient()).logout();
  appRouter.go(AppRoutes.login);
}

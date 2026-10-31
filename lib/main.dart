import 'package:flutter/material.dart';

import 'package:costbook/app.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/auth/repository/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLang.load('th');
  await AuthRepository(ApiClient()).loadSavedToken();
  runApp(const App());
}

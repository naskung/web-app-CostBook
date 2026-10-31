import 'package:flutter/material.dart';

import 'package:costbook/app.dart';
import 'package:costbook/core/lang/app_lang.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLang.load('th');
  runApp(const App());
}

import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: เปลี่ยนเป็น MaterialApp.router + LanguageBloc ตอนทำภาษาและ route (Phase 2)
    return MaterialApp(
      title: 'CostBook',
      theme: AppTheme.light,
      home: const Scaffold(),
    );
  }
}

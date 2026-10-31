import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/organisms/screen_scaler.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CostBook',
      theme: AppTheme.light,
      builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()),
      home: const Scaffold(),
    );
  }
}

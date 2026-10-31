import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/lang/language_bloc.dart';
import 'package:costbook/core/routes/app_router.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/organisms/screen_scaler.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LanguageBloc(),
      child: BlocBuilder<LanguageBloc, String>(
        builder: (context, langCode) => MaterialApp.router(
          key: ValueKey(langCode),
          title: 'CostBook',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          builder: (context, child) => ScreenScaler(
            child: ColoredBox(color: AppColors.background, child: child ?? const SizedBox()),
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}

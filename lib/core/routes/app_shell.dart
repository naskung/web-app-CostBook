import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_menu.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/shared/widgets/organisms/page_layout.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current.status == AppStatus.success,
      listener: (context, state) => context.go(AppRoutes.login),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) => previous.company.useCostPage != current.company.useCostPage,
        builder:
            (context, settings) => PageLayout(
              title: AppMenu.titleOf(currentPath),
              menuItems: AppMenu.itemsFor(useCostPage: settings.company.useCostPage),
              appName: 'app.name'.tr,
              logoutLabel: 'common.logout'.tr,
              menuButtonLabel: 'common.toggle_menu'.tr,
              currentPath: currentPath,
              onNavigate: (route) => context.go(route),
              onLogout: () => context.read<AuthBloc>().add(LogoutRequested()),
              child: child,
            ),
      ),
    );
  }
}

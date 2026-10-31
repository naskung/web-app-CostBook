import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current.status == AppStatus.success,
      listener: (context, state) => context.go(AppRoutes.login),
      child: Scaffold(
        appBar: AppBar(
          title: Text('app.name'.tr),
          actions: [
            TextButton.icon(
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
              icon: const Icon(Icons.logout),
              label: Text('common.logout'.tr),
            ),
            const SizedBox(width: AppSizes.spaceSmall),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceLarge),
            child: Text(
              'dashboard.welcome'.tr,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_menu.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/assistant/widgets/chat_launcher.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/widgets/user_avatar.dart';
import 'package:costbook/shared/widgets/organisms/app_side_menu.dart';
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
            (context, settings) => BlocBuilder<ProfileBloc, ProfileState>(
              buildWhen: (previous, current) => previous.user != current.user,
              builder: (context, profile) => _layout(context, settings, profile),
            ),
      ),
    );
  }

  Widget _layout(BuildContext context, SettingsState settings, ProfileState profile) {
    return Stack(
      children: [
        PageLayout(
          title: AppMenu.titleOf(currentPath),
          menuItems: AppMenu.itemsFor(useCostPage: settings.company.useCostPage),
          appName: 'app.name'.tr,
          logoutLabel: 'common.logout'.tr,
          menuButtonLabel: 'common.toggle_menu'.tr,
          currentPath: currentPath,
          onNavigate: (route) => context.go(route),
          onLogout: () => context.read<AuthBloc>().add(LogoutRequested()),
          profile: _menuProfile(profile),
          child: child,
        ),
        ChatLauncher(bottom: _chatBottom(context)),
      ],
    );
  }

  // หน้าขายบนมือถือมีแถบยอดรวมติดล่าง → ยกปุ่มแชทขึ้นไปเหนือแถบ ไม่ทับปุ่มดูบิล
  double _chatBottom(BuildContext context) {
    final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
    if (!isMobile || currentPath != AppRoutes.sell) return AppSizes.spaceLarge;
    return AppSizes.sellCartBarHeight + AppSizes.spaceMedium + MediaQuery.paddingOf(context).bottom;
  }

  // ยังโหลดผู้ใช้ไม่เสร็จ → ยังไม่แสดงแถวผู้ใช้
  SideMenuProfile? _menuProfile(ProfileState profile) {
    final user = profile.user;
    if (user.isNew) return null;
    return SideMenuProfile(
      name: user.displayName,
      subtitle: user.role.labelKey.tr,
      avatar: UserAvatar(user: user),
      route: AppRoutes.profile,
    );
  }
}

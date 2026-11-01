import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/widgets/password_section.dart';
import 'package:costbook/features/user/widgets/profile_info_section.dart';
import 'package:costbook/features/user/widgets/profile_photo_card.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';

// โปรไฟล์ของผู้ใช้ที่ login อยู่ (ใช้ ProfileBloc ของ shell) / เจ้าของร้านมีปุ่มไปหน้าจัดการผู้ใช้
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen:
          (previous, current) => previous.status != current.status || previous.user.isOwner != current.user.isOwner,
      builder: (context, state) {
        final stateView = _stateView(context, state);
        return PageContent(
          maxWidth: AppSizes.profileFormMaxWidth,
          centerChild: stateView,
          children: [
            if (stateView == null) ...[
              const ProfilePhotoCard(),
              if (state.user.isOwner) _usersCard(context),
              const ProfileInfoSection(),
              const PasswordSection(),
            ],
          ],
        );
      },
    );
  }

  // โหลดใหม่ตอนมีข้อมูลอยู่แล้ว (เช่น หลังแก้ผู้ใช้) ไม่ต้องขึ้นหน้าโหลด — ฟอร์มที่กรอกค้างไว้ไม่หาย
  Widget? _stateView(BuildContext context, ProfileState state) {
    if (!state.user.isNew) return null;
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<ProfileBloc>().add(ProfileRequested()),
      );
    }
    return const AppLoading();
  }

  Widget _usersCard(BuildContext context) {
    return SectionCard(
      title: 'profile.users_title'.tr,
      subtitle: 'profile.users_hint'.tr,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: () => context.go(AppRoutes.users),
          icon: const Icon(Icons.group_outlined),
          label: Text('profile.manage_users'.tr),
        ),
      ),
    );
  }
}

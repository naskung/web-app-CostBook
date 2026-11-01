import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/image_pick_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/widgets/role_badge.dart';
import 'package:costbook/features/user/widgets/user_avatar.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';

// การ์ดบนสุดของหน้าโปรไฟล์: รูป + ชื่อ + อีเมล + role / เปลี่ยน-ลบรูปได้
class ProfilePhotoCard extends StatelessWidget {
  const ProfilePhotoCard({super.key});

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    final bytes = await ImagePickHelper.pick();
    if (bytes == null || !context.mounted) return;
    if (bytes.length > ImagePickHelper.maxBytes) {
      SnackbarHelper.showError(context, 'error.avatar_too_large'.tr);
      return;
    }
    bloc.add(AvatarUploaded(bytes));
  }

  Future<void> _remove(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'profile.photo_remove_title'.tr,
      message: 'profile.photo_remove_message'.tr,
      confirmText: 'profile.photo_remove'.tr,
    );
    if (isConfirmed) bloc.add(AvatarRemoved());
  }

  void _onResult(BuildContext context, ProfileState state) {
    if (state.avatarStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'profile.photo_saved'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.avatarErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen:
          (previous, current) =>
              previous.avatarStatus == AppStatus.loading && current.avatarStatus != AppStatus.loading,
      listener: _onResult,
      builder: (context, state) {
        return SectionCard(
          title: 'profile.account_title'.tr,
          child: Row(
            children: [
              UserAvatar(user: state.user, size: AppSizes.profileAvatarSize),
              const SizedBox(width: AppSizes.spaceLarge),
              Expanded(child: _details(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _details(BuildContext context, ProfileState state) {
    final textTheme = Theme.of(context).textTheme;
    final user = state.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.displayName, style: textTheme.titleLarge),
        Text(user.email, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSizes.spaceSmall),
        RoleBadge(role: user.role),
        const SizedBox(height: AppSizes.spaceMedium),
        _photoButtons(context, state),
      ],
    );
  }

  Widget _photoButtons(BuildContext context, ProfileState state) {
    final isSaving = state.avatarStatus == AppStatus.loading;
    return Wrap(
      spacing: AppSizes.spaceSmall,
      runSpacing: AppSizes.spaceSmall,
      children: [
        OutlinedButton.icon(
          onPressed: isSaving ? null : () => _pick(context),
          icon: _pickIcon(isSaving),
          label: Text(state.user.hasAvatar ? 'profile.photo_change'.tr : 'profile.photo_pick'.tr),
        ),
        if (state.user.hasAvatar)
          TextButton.icon(
            onPressed: isSaving ? null : () => _remove(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.delete_outline),
            label: Text('profile.photo_remove'.tr),
          ),
      ],
    );
  }

  Widget _pickIcon(bool isSaving) {
    if (!isSaving) return const Icon(Icons.photo_camera_outlined);
    return const SizedBox.square(
      dimension: AppSizes.iconSmall,
      child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
    );
  }
}

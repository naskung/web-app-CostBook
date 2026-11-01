import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/image_pick_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    final bytes = await ImagePickHelper.pick();
    if (bytes == null || !context.mounted) return;
    if (bytes.length > ImagePickHelper.maxBytes) {
      SnackbarHelper.showError(context, 'error.logo_too_large'.tr);
      return;
    }
    bloc.add(LogoUploaded(bytes));
  }

  Future<void> _remove(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'settings.logo_remove_title'.tr,
      message: 'settings.logo_remove_message'.tr,
      confirmText: 'settings.logo_remove'.tr,
    );
    if (isConfirmed) bloc.add(LogoRemoved());
  }

  void _onResult(BuildContext context, SettingsState state) {
    if (state.logoStatus == AppStatus.success) {
      ShopLogo.refresh();
      SnackbarHelper.showSuccess(context, 'settings.logo_saved'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.logoErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen:
          (previous, current) => previous.logoStatus == AppStatus.loading && current.logoStatus != AppStatus.loading,
      listener: _onResult,
      builder: (context, state) {
        return SectionCard(
          title: 'settings.logo_title'.tr,
          child: Row(
            children: [
              const ShopLogo(size: AppSizes.logoSize, radius: AppSizes.radiusLarge),
              const SizedBox(width: AppSizes.spaceLarge),
              Expanded(child: _details(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _details(BuildContext context, SettingsState state) {
    final textTheme = Theme.of(context).textTheme;
    final isSaving = state.logoStatus == AppStatus.loading;
    final hasLogo = state.company.hasLogo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('settings.logo_hint'.tr, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSizes.spaceXSmall),
        Text('settings.logo_file_hint'.tr, style: textTheme.bodySmall),
        const SizedBox(height: AppSizes.spaceMedium),
        Wrap(
          spacing: AppSizes.spaceSmall,
          runSpacing: AppSizes.spaceSmall,
          children: [
            OutlinedButton.icon(
              onPressed: isSaving ? null : () => _pick(context),
              icon: _pickIcon(isSaving),
              label: Text(hasLogo ? 'settings.logo_change'.tr : 'settings.logo_pick'.tr),
            ),
            if (hasLogo)
              TextButton.icon(
                onPressed: isSaving ? null : () => _remove(context),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                icon: const Icon(Icons.delete_outline),
                label: Text('settings.logo_remove'.tr),
              ),
          ],
        ),
      ],
    );
  }

  Widget _pickIcon(bool isSaving) {
    if (!isSaving) return const Icon(Icons.photo_library_outlined);
    return const SizedBox.square(
      dimension: AppSizes.iconSmall,
      child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
    );
  }
}

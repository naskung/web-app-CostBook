import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';

class AiKeySection extends StatefulWidget {
  const AiKeySection({super.key});

  @override
  State<AiKeySection> createState() => _AiKeySectionState();
}

class _AiKeySectionState extends State<AiKeySection> {
  final _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _remove() async {
    final bloc = context.read<AssistantBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'settings.ai_remove_title'.tr,
      message: 'settings.ai_remove_message'.tr,
      confirmText: 'settings.ai_remove'.tr,
    );
    if (isConfirmed) bloc.add(AssistantKeyRemoved());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssistantBloc, AssistantState>(
      listenWhen: (previous, current) => previous.keyStatus != current.keyStatus,
      listener: (context, state) {
        if (state.keyStatus != AppStatus.success) return;
        _keyController.clear();
        SnackbarHelper.showSuccess(context, 'settings.ai_saved'.tr);
      },
      builder: (context, state) {
        final textTheme = Theme.of(context).textTheme;
        final isSaving = state.keyStatus == AppStatus.loading;
        return SectionCard(
          title: 'settings.ai_title'.tr,
          subtitle: 'settings.ai_subtitle'.tr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _current(context, state.ai),
              const SizedBox(height: AppSizes.spaceMedium),
              AppTextField(
                label: state.ai.hasOwnKey ? 'settings.ai_key_change'.tr : 'settings.ai_key'.tr,
                hint: 'sk-ant-...',
                controller: _keyController,
                icon: Icons.key_outlined,
                isPassword: true,
                onSubmitted: (_) => context.read<AssistantBloc>().add(AssistantKeySaved(_keyController.text)),
              ),
              const SizedBox(height: AppSizes.spaceXSmall),
              Text('settings.ai_key_hint'.tr, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              if (state.keyStatus == AppStatus.failure) ...[
                const SizedBox(height: AppSizes.spaceSmall),
                Text('error.${state.keyErrorCode}'.tr, style: textTheme.bodyMedium?.copyWith(color: AppColors.danger)),
              ],
              const SizedBox(height: AppSizes.spaceMedium),
              Wrap(
                spacing: AppSizes.spaceSmall,
                runSpacing: AppSizes.spaceSmall,
                alignment: WrapAlignment.end,
                children: [
                  if (state.ai.hasOwnKey)
                    OutlinedButton(onPressed: isSaving ? null : _remove, child: Text('settings.ai_remove'.tr)),
                  SizedBox(
                    width: AppSizes.rankedLabelWidth * 1.3,
                    child: AppButton(
                      text: 'settings.ai_save'.tr,
                      isLoading: isSaving,
                      onPressed: () => context.read<AssistantBloc>().add(AssistantKeySaved(_keyController.text)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _current(BuildContext context, AiStatusModel ai) {
    final textTheme = Theme.of(context).textTheme;
    final isClaude = ai.provider == AiStatusModel.claude;
    final label = switch (ai.provider) {
      AiStatusModel.claude =>
        ai.hasOwnKey ? 'settings.ai_using_own'.trParams({'hint': ai.keyHint}) : 'settings.ai_using_env'.tr,
      AiStatusModel.gemini => 'settings.ai_using_free'.tr,
      _ => 'settings.ai_using_none'.tr,
    };
    final detail = isClaude ? 'settings.ai_claude_detail'.tr : 'settings.ai_free_detail'.tr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('settings.ai_current'.tr, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: AppSizes.spaceSmall),
            Flexible(
              child: AppBadge(
                text: label,
                color: ai.enabled ? AppColors.success : AppColors.textSecondary,
                backgroundColor: ai.enabled ? AppColors.successSoft : AppColors.neutralSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceXSmall),
        Text(ai.enabled ? detail : 'settings.ai_none_detail'.tr, style: textTheme.bodySmall),
      ],
    );
  }
}

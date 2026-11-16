import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/models/ai_preset_model.dart';
import 'package:costbook/features/assistant/models/ai_settings_model.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/settings/widgets/openai_fields.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';

class AiSettingsSection extends StatefulWidget {
  const AiSettingsSection({super.key});

  @override
  State<AiSettingsSection> createState() => _AiSettingsSectionState();
}

class _AiSettingsSectionState extends State<AiSettingsSection> {
  final _keyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  String _presetId = AiPresetModel.claudeId;

  bool get _isClaude => _presetId == AiPresetModel.claudeId;

  Map<String, String> get _providerItems {
    return {
      AiPresetModel.claudeId: 'settings.ai_provider_claude'.tr,
      for (final preset in AiPresetModel.all)
        preset.id: preset.noteKey.isEmpty ? preset.name : '${preset.name} (${preset.noteKey.tr})',
      AiPresetModel.customId: 'ai_preset.custom'.tr,
    };
  }

  @override
  void initState() {
    super.initState();
    _showSaved(context.read<AssistantBloc>().state.ai);
  }

  @override
  void dispose() {
    _keyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _showSaved(AiStatusModel ai) {
    if (ai.source != 'settings') return;
    if (ai.provider == AiStatusModel.claude) {
      _presetId = AiPresetModel.claudeId;
      return;
    }
    if (ai.provider != AiStatusModel.openai) return;
    _presetId = AiPresetModel.idOfBaseUrl(ai.baseUrl);
    _baseUrlController.text = ai.baseUrl;
    _modelController.text = ai.model;
  }

  void _changePreset(String id) {
    setState(() {
      _presetId = id;
      final preset = AiPresetModel.byId(id);
      if (preset == null) return;
      _baseUrlController.text = preset.baseUrl;
      _modelController.clear();
    });
  }

  void _fetchModels() {
    context.read<AssistantBloc>().add(
      AssistantModelsRequested(baseUrl: _baseUrlController.text, apiKey: _keyController.text),
    );
  }

  void _save() {
    final settings =
        _isClaude
            ? AiSettingsModel(provider: AiStatusModel.claude, apiKey: _keyController.text)
            : AiSettingsModel(
              provider: AiStatusModel.openai,
              apiKey: _keyController.text,
              baseUrl: _baseUrlController.text,
              model: _modelController.text,
            );
    context.read<AssistantBloc>().add(AssistantAiSaved(settings));
  }

  Future<void> _remove() async {
    final bloc = context.read<AssistantBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'settings.ai_remove_title'.tr,
      message: 'settings.ai_remove_message'.tr,
      confirmText: 'settings.ai_remove'.tr,
      icon: Icons.key_off_outlined,
    );
    if (isConfirmed) bloc.add(AssistantKeyRemoved());
  }

  void _onSaved(BuildContext context, AssistantState state) {
    if (state.keyStatus != AppStatus.success) return;
    _keyController.clear();
    SnackbarHelper.showSuccess(context, 'settings.ai_saved'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AssistantBloc, AssistantState>(
          listenWhen: (previous, current) => previous.keyStatus != current.keyStatus,
          listener: _onSaved,
        ),
        BlocListener<AssistantBloc, AssistantState>(
          listenWhen: (previous, current) => previous.ai != current.ai,
          listener: (context, state) => setState(() => _showSaved(state.ai)),
        ),
      ],
      child: BlocBuilder<AssistantBloc, AssistantState>(
        builder:
            (context, state) => SectionCard(
              title: 'settings.ai_title'.tr,
              subtitle: 'settings.ai_subtitle'.tr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AiCurrentStatus(ai: state.ai),
                  const SizedBox(height: AppSizes.spaceMedium),
                  AppDropdown<String>(
                    label: 'settings.ai_service'.tr,
                    value: _presetId,
                    items: _providerItems,
                    onChanged: (id) => _changePreset(id ?? AiPresetModel.customId),
                  ),
                  const SizedBox(height: AppSizes.spaceMedium),
                  if (_isClaude) _claudeFields(context) else _openAiFields(state),
                  if (state.keyStatus == AppStatus.failure) ...[
                    const SizedBox(height: AppSizes.spaceSmall),
                    Text(
                      'error.${state.keyErrorCode}'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spaceMedium),
                  _buttons(state),
                ],
              ),
            ),
      ),
    );
  }

  Widget _claudeFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'settings.ai_key'.tr,
          hint: 'sk-ant-...',
          controller: _keyController,
          icon: Icons.key_outlined,
          isPassword: true,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSizes.spaceXSmall),
        Text(
          'settings.ai_key_hint'.tr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _openAiFields(AssistantState state) {
    return OpenAiFields(
      baseUrlController: _baseUrlController,
      keyController: _keyController,
      modelController: _modelController,
      models: state.models,
      modelsStatus: state.modelsStatus,
      modelsErrorCode: state.modelsErrorCode,
      onFetchModels: _fetchModels,
    );
  }

  Widget _buttons(AssistantState state) {
    final isSaving = state.keyStatus == AppStatus.loading;
    return Wrap(
      spacing: AppSizes.spaceSmall,
      runSpacing: AppSizes.spaceSmall,
      alignment: WrapAlignment.end,
      children: [
        if (state.ai.hasOwnKey)
          OutlinedButton(onPressed: isSaving ? null : _remove, child: Text('settings.ai_remove'.tr)),
        SizedBox(
          width: AppSizes.rankedLabelWidth * 1.3,
          child: AppButton(text: 'settings.ai_save'.tr, isLoading: isSaving, onPressed: _save),
        ),
      ],
    );
  }
}

class AiCurrentStatus extends StatelessWidget {
  const AiCurrentStatus({super.key, required this.ai});

  final AiStatusModel ai;

  String get _label {
    return switch (ai.provider) {
      AiStatusModel.claude =>
        ai.hasOwnKey ? 'settings.ai_using_own'.trParams({'hint': ai.keyHint}) : 'settings.ai_using_env'.tr,
      AiStatusModel.openai => 'settings.ai_using_openai'.trParams({'model': ai.model, 'host': ai.baseUrlHost}),
      AiStatusModel.gemini => 'settings.ai_using_free'.tr,
      _ => 'settings.ai_using_none'.tr,
    };
  }

  String get _detail {
    if (!ai.enabled) return 'settings.ai_none_detail'.tr;
    if (ai.provider == AiStatusModel.claude) return 'settings.ai_claude_detail'.tr;
    if (ai.provider == AiStatusModel.openai) {
      return ai.webSearch ? 'settings.ai_openai_search_detail'.tr : 'settings.ai_openai_detail'.tr;
    }
    if (ai.webSearch) return 'settings.ai_free_search_detail'.tr;
    return 'settings.ai_free_detail'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('settings.ai_current'.tr, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: AppSizes.spaceSmall),
            Flexible(
              child: AppBadge(
                text: _label,
                color: ai.enabled ? AppColors.success : AppColors.textSecondary,
                backgroundColor: ai.enabled ? AppColors.successSoft : AppColors.neutralSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceXSmall),
        Text(_detail, style: textTheme.bodySmall),
      ],
    );
  }
}

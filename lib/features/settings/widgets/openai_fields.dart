import 'package:flutter/material.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';

class OpenAiFields extends StatelessWidget {
  const OpenAiFields({
    super.key,
    required this.baseUrlController,
    required this.keyController,
    required this.modelController,
    required this.models,
    required this.modelsStatus,
    required this.modelsErrorCode,
    required this.onFetchModels,
  });

  final TextEditingController baseUrlController;
  final TextEditingController keyController;
  final TextEditingController modelController;
  final List<String> models;
  final AppStatus modelsStatus;
  final String modelsErrorCode;
  final VoidCallback onFetchModels;

  @override
  Widget build(BuildContext context) {
    final hintStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'settings.ai_base_url'.tr,
          hint: 'https://.../v1',
          controller: baseUrlController,
          icon: Icons.link,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: AppSizes.spaceMedium),
        AppTextField(
          label: 'settings.ai_openai_key'.tr,
          hint: 'sk-...',
          controller: keyController,
          icon: Icons.key_outlined,
          isPassword: true,
        ),
        const SizedBox(height: AppSizes.spaceXSmall),
        Text('settings.ai_openai_key_hint'.tr, style: hintStyle),
        const SizedBox(height: AppSizes.spaceMedium),
        _modelRow(context),
        if (modelsStatus == AppStatus.success) ...[
          const SizedBox(height: AppSizes.spaceXSmall),
          Text(_modelsNote(), style: hintStyle),
        ],
        if (modelsStatus == AppStatus.failure) ...[
          const SizedBox(height: AppSizes.spaceXSmall),
          Text(
            'error.$modelsErrorCode'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }

  String _modelsNote() {
    if (models.isEmpty) return 'settings.ai_models_none'.tr;
    return 'settings.ai_models_found'.trParams({'count': '${models.length}'});
  }

  Widget _modelRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: ModelField(controller: modelController, models: models)),
        const SizedBox(width: AppSizes.spaceSmall),
        SizedBox(
          height: AppSizes.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: modelsStatus == AppStatus.loading ? null : onFetchModels,
            icon:
                modelsStatus == AppStatus.loading
                    ? const SizedBox.square(
                      dimension: AppSizes.loadingSize,
                      child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
                    )
                    : const Icon(Icons.download_outlined),
            label: Text('settings.ai_fetch_models'.tr),
          ),
        ),
      ],
    );
  }
}

class ModelField extends StatefulWidget {
  const ModelField({super.key, required this.controller, required this.models});

  final TextEditingController controller;
  final List<String> models;

  @override
  State<ModelField> createState() => _ModelFieldState();
}

class _ModelFieldState extends State<ModelField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Iterable<String> _matches(TextEditingValue value) {
    final typed = value.text.trim().toLowerCase();
    return widget.models.where((model) => model.toLowerCase().contains(typed));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('settings.ai_model'.tr, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSizes.spaceSmall),
        LayoutBuilder(
          builder:
              (context, constraints) => RawAutocomplete<String>(
                textEditingController: widget.controller,
                focusNode: _focusNode,
                optionsBuilder: _matches,
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'settings.ai_model_hint'.tr,
                        prefixIcon: const Icon(Icons.memory_outlined),
                      ),
                    ),
                optionsViewBuilder:
                    (context, onSelected, options) => _options(onSelected, options, constraints.maxWidth),
              ),
        ),
      ],
    );
  }

  Widget _options(AutocompleteOnSelected<String> onSelected, Iterable<String> options, double width) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: AppSizes.buttonHoverElevation * 2,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: AppSizes.autocompleteMaxHeight),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              for (final option in options) ListTile(dense: true, title: Text(option), onTap: () => onSelected(option)),
            ],
          ),
        ),
      ),
    );
  }
}

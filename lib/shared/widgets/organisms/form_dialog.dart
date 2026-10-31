import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';

class FormDialog extends StatelessWidget {
  const FormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.saveLabel,
    required this.cancelLabel,
    required this.onSave,
    this.isSaving = false,
    this.errorText = '',
  });

  final String title;
  final Widget child;
  final String saveLabel;
  final String cancelLabel;
  final VoidCallback onSave;
  final bool isSaving;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSizes.spaceMedium),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.dialogMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.spaceLarge, AppSizes.spaceLarge, AppSizes.spaceLarge, 0),
              child: Text(title, style: textTheme.titleLarge),
            ),
            Flexible(
              child: SingleChildScrollView(padding: const EdgeInsets.all(AppSizes.spaceLarge), child: child),
            ),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceLarge),
                child: Text(errorText, style: textTheme.bodyMedium?.copyWith(color: AppColors.danger)),
              ),
            _actions(context),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: isSaving ? null : () => Navigator.pop(context), child: Text(cancelLabel)),
          const SizedBox(width: AppSizes.spaceSmall),
          AppButton(text: saveLabel, isLoading: isSaving, onPressed: onSave),
        ],
      ),
    );
  }
}

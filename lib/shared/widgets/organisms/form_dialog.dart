import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/organisms/app_dialog.dart';

// กล่องฟอร์ม (เพิ่ม / แก้ข้อมูล) ใช้โครง AppDialog + ปุ่มยกเลิก / บันทึก + กล่อง error เหนือปุ่ม
class FormDialog extends StatelessWidget {
  const FormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.saveLabel,
    required this.cancelLabel,
    required this.onSave,
    this.icon,
    this.subtitle = '',
    this.isSaving = false,
    this.errorText = '',
  });

  final String title;
  final Widget child;
  final String saveLabel;
  final String cancelLabel;
  final VoidCallback onSave;
  final IconData? icon;
  final String subtitle;
  final bool isSaving;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      subtitle: subtitle,
      icon: icon,
      closeLabel: cancelLabel,
      canClose: !isSaving,
      notice: errorText.isEmpty ? null : _ErrorNotice(text: errorText),
      actions: [
        AppButton(
          text: cancelLabel,
          variant: AppButtonVariant.secondary,
          onPressed: isSaving ? null : () => Navigator.pop(context),
        ),
        AppButton(text: saveLabel, isLoading: isSaving, onPressed: onSave),
      ],
      child: child,
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmall + AppSizes.spaceXSmall),
      decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: AppSizes.iconSmall),
          const SizedBox(width: AppSizes.spaceSmall),
          Expanded(child: Text(text, style: textTheme.bodyMedium?.copyWith(color: AppColors.danger))),
        ],
      ),
    );
  }
}

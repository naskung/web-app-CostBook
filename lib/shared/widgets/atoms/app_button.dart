import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

// primary = ปุ่มหลักสีส้ม, secondary = ปุ่มขอบ (ยกเลิก / ปิด), danger = ปุ่มสีแดง (ลบ)
enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;

  static final ButtonStyle _secondaryStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    minimumSize: const Size(0, AppSizes.buttonHeight),
    side: const BorderSide(color: AppColors.inputBorder),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius)),
  );

  static final ButtonStyle _dangerStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.danger,
    foregroundColor: AppColors.onDark,
  );

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;
    if (variant == AppButtonVariant.secondary) {
      return OutlinedButton(onPressed: onTap, style: _secondaryStyle, child: _label());
    }
    final style = variant == AppButtonVariant.danger ? _dangerStyle : null;
    return ElevatedButton(onPressed: onTap, style: style, child: _label());
  }

  Widget _label() {
    if (isLoading) {
      return const SizedBox.square(
        dimension: AppSizes.loadingSize,
        child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
      );
    }
    if (icon == null) return Text(text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSmall),
        const SizedBox(width: AppSizes.spaceSmall),
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

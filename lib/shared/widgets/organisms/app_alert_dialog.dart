import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';

// กล่องข้อความสั้น ๆ ไอคอนวงกลมอยู่ตรงกลาง
// isDanger = true → สีแดง (ยืนยันลบ / ยกเลิก), false → สีเขียว (แจ้งว่าทำสำเร็จ)
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.onPrimary,
    this.secondaryText = '',
    this.onSecondary,
    this.isDanger = true,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryText;
  final VoidCallback onPrimary;
  final String secondaryText;
  final VoidCallback? onSecondary;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
    return Dialog(
      insetPadding: EdgeInsets.all(isMobile ? AppSizes.dialogMobileInset : AppSizes.spaceLarge),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.alertMaxWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.alertIconBox,
                height: AppSizes.alertIconBox,
                decoration: BoxDecoration(
                  color: isDanger ? AppColors.dangerSoft : AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppSizes.alertIcon, color: isDanger ? AppColors.danger : AppColors.success),
              ),
              const SizedBox(height: AppSizes.spaceMedium),
              Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.spaceSmall),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceLarge),
              Row(
                children: [
                  if (secondaryText.isNotEmpty) ...[
                    Expanded(
                      child: AppButton(
                        text: secondaryText,
                        onPressed: onSecondary,
                        variant: AppButtonVariant.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSmall),
                  ],
                  Expanded(
                    child: AppButton(
                      text: primaryText,
                      onPressed: onPrimary,
                      variant: isDanger ? AppButtonVariant.danger : AppButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

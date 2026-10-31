import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class DashboardPanel extends StatelessWidget {
  const DashboardPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.height,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasHeight = height != null;
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSizes.panelPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.panelRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              if (trailing != null) trailing ?? const SizedBox(),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.spaceXSmall),
            Text(subtitle ?? '', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: AppSizes.spaceMedium),
          if (hasHeight) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

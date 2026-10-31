import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      padding: const EdgeInsets.all(AppSizes.spaceLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleMedium)),
              if (trailing != null) trailing ?? const SizedBox(),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.spaceXSmall),
            Text(subtitle ?? '', style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: AppSizes.spaceMedium),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class NoticeBanner extends StatelessWidget {
  const NoticeBanner({super.key, required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMedium, vertical: AppSizes.spaceSmall),
      decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textPrimary),
          const SizedBox(width: AppSizes.spaceSmall),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel ?? '')),
        ],
      ),
    );
  }
}

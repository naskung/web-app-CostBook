import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.caption,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.iconBox,
            height: AppSizes.iconBox,
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(AppSizes.radius)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSizes.spaceXSmall),
                Text(value, style: textTheme.titleLarge?.copyWith(color: color), overflow: TextOverflow.ellipsis),
                if (caption != null) Text(caption ?? '', style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

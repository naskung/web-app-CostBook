import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/delta_pill.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.change,
    this.upIsGood = true,
    this.caption = '',
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double? change;
  final bool upIsGood;
  final String caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.panelPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.panelRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
              Icon(icon, size: AppSizes.iconSmall, color: iconColor),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          Wrap(
            spacing: AppSizes.spaceSmall,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: AppSizes.kpiFont,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
              DeltaPill(change: change, upIsGood: upIsGood),
            ],
          ),
          const SizedBox(height: AppSizes.spaceXSmall),
          Text(caption, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

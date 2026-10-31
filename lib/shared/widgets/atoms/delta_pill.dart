import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/percent_util.dart';

class DeltaPill extends StatelessWidget {
  const DeltaPill({super.key, required this.change, this.upIsGood = true});

  final double? change;
  final bool upIsGood;

  @override
  Widget build(BuildContext context) {
    final value = change;
    if (value == null) return const SizedBox();
    final isUp = value > 0;
    final isNeutral = value == 0;
    final isGood = isUp == upIsGood;
    final color = isNeutral ? AppColors.textSecondary : (isGood ? AppColors.success : AppColors.danger);
    final background = isNeutral ? AppColors.neutralSoft : (isGood ? AppColors.successSoft : AppColors.dangerSoft);
    final icon = isNeutral ? Icons.trending_flat : (isUp ? Icons.trending_up : Icons.trending_down);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSmall, vertical: AppSizes.badgePaddingY),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.fontBody, color: color),
          const SizedBox(width: AppSizes.spaceXSmall),
          Text(
            PercentUtil.format(value),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

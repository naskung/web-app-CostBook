import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class ChartLegendItem {
  const ChartLegendItem({required this.label, required this.color});

  final String label;
  final Color color;
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});

  final List<ChartLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    return Wrap(
      spacing: AppSizes.spaceMedium,
      runSpacing: AppSizes.spaceXSmall,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.legendSwatch,
                height: AppSizes.legendSwatch,
                decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(AppSizes.spaceXSmall)),
              ),
              const SizedBox(width: AppSizes.spaceXSmall),
              Text(item.label, style: style),
            ],
          ),
      ],
    );
  }
}

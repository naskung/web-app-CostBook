import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.label,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onPrevious, tooltip: previousTooltip, icon: const Icon(Icons.chevron_left)),
          SizedBox(
            width: AppSizes.monthLabelWidth,
            child: Text(label, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
          ),
          IconButton(onPressed: onNext, tooltip: nextTooltip, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

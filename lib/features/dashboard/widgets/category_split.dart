import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/percent_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';

class CategorySplit extends StatelessWidget {
  const CategorySplit({super.key, required this.title, required this.categories, required this.emptyName});

  final String title;
  final List<CategoryAmountModel> categories;
  final String emptyName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: textTheme.titleSmall),
          const SizedBox(height: AppSizes.spaceSmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.spaceSmall),
                Expanded(child: _item(context, categories[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, CategoryAmountModel category) {
    final textTheme = Theme.of(context).textTheme;
    final name = category.category.isEmpty ? emptyName : category.category;
    return Tooltip(
      message: '$name ${MoneyUtil.format(category.amount)} (${PercentUtil.format(category.percent)})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MoneyUtil.formatShort(category.amount),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$name · ${PercentUtil.format(category.percent)}',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.spaceSmall),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(height: AppSizes.splitBarHeight, color: AppColors.chartTrack),
                  Container(
                    width: constraints.maxWidth * (category.percent / 100).clamp(0.0, 1.0),
                    height: AppSizes.splitBarHeight,
                    color: AppColors.chartIncome,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

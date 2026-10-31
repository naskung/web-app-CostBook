import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';

class SellProductTile extends StatelessWidget {
  const SellProductTile({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.stockText,
    required this.width,
    required this.isOut,
    required this.onTap,
  });

  final Widget image;
  final String name;
  final double price;
  final String stockText;
  final double width;
  final bool isOut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spaceMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                image,
                const SizedBox(height: AppSizes.spaceSmall),
                Text(name, style: textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSizes.spaceSmall),
                Text(MoneyUtil.format(price), style: textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                Text(stockText, style: textTheme.bodySmall?.copyWith(color: isOut ? AppColors.danger : null)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

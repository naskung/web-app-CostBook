import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';

class StockStatusBadge extends StatelessWidget {
  const StockStatusBadge({super.key, required this.isOutOfStock, required this.isLowStock});

  final bool isOutOfStock;
  final bool isLowStock;

  @override
  Widget build(BuildContext context) {
    if (isOutOfStock) {
      return AppBadge(text: 'product.out_of_stock'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft);
    }
    if (isLowStock) {
      return AppBadge(text: 'product.low'.tr, color: AppColors.warning, backgroundColor: AppColors.warningSoft);
    }
    return const SizedBox.shrink();
  }
}

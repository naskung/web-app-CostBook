import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/percent_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';

class TopProductsColumns {
  const TopProductsColumns({
    required this.rank,
    required this.product,
    required this.sold,
    required this.sales,
    required this.profit,
    required this.margin,
  });

  final String rank;
  final String product;
  final String sold;
  final String sales;
  final String profit;
  final String margin;
}

class TopProductsTable extends StatelessWidget {
  const TopProductsTable({super.key, required this.products, required this.labels});

  final List<ProductSalesModel> products;
  final TopProductsColumns labels;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppSizes.tableCompactBreak;
        return Column(
          children: [
            _header(context, isCompact),
            for (var i = 0; i < products.length; i++) ...[
              const Divider(height: 1),
              _row(context, i, products[i], isCompact),
            ],
          ],
        );
      },
    );
  }

  Widget _cell(Widget child, int flex, {bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Align(alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft, child: child),
    );
  }

  Widget _header(BuildContext context, bool isCompact) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
      child: Row(
        children: [
          if (!isCompact) _cell(Text(labels.rank, style: style), 1),
          _cell(Text(labels.product, style: style), 5),
          if (!isCompact) _cell(Text(labels.sold, style: style), 2, alignEnd: true),
          _cell(Text(labels.sales, style: style), 3, alignEnd: true),
          if (!isCompact) _cell(Text(labels.profit, style: style), 3, alignEnd: true),
          _cell(Text(labels.margin, style: style), 2, alignEnd: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, int index, ProductSalesModel product, bool isCompact) {
    final textTheme = Theme.of(context).textTheme;
    final isLoss = product.profit < 0;
    final profitColor = isLoss ? AppColors.danger : AppColors.success;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSmall),
      child: Row(
        children: [
          if (!isCompact) _cell(Text('#${index + 1}', style: textTheme.bodySmall), 1),
          _cell(_name(context, product, isCompact), 5),
          if (!isCompact)
            _cell(Text('${product.quantity} ${product.unit}', style: textTheme.bodyMedium), 2, alignEnd: true),
          _cell(Text(MoneyUtil.format(product.netSales), style: textTheme.bodyMedium), 3, alignEnd: true),
          if (!isCompact)
            _cell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isLoss ? Icons.trending_down : Icons.trending_up, size: AppSizes.fontBody, color: profitColor),
                  const SizedBox(width: AppSizes.spaceXSmall),
                  Text(MoneyUtil.format(product.profit), style: textTheme.titleSmall?.copyWith(color: profitColor)),
                ],
              ),
              3,
              alignEnd: true,
            ),
          _cell(Text(PercentUtil.format(product.margin), style: textTheme.bodyMedium), 2, alignEnd: true),
        ],
      ),
    );
  }

  Widget _name(BuildContext context, ProductSalesModel product, bool isCompact) {
    final textTheme = Theme.of(context).textTheme;
    final initial = product.name.isEmpty ? '?' : product.name.characters.first;
    return Row(
      children: [
        Container(
          width: AppSizes.avatarSize,
          height: AppSizes.avatarSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.neutralSoft,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(initial, style: textTheme.titleSmall),
        ),
        const SizedBox(width: AppSizes.spaceSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis),
              if (isCompact) Text('${product.quantity} ${product.unit}', style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

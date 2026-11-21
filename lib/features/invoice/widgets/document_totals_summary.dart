import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/tax_util.dart';

class DocumentTotalsSummary extends StatelessWidget {
  const DocumentTotalsSummary({
    super.key,
    required this.amounts,
    required this.showVat,
    required this.pricesIncludeVat,
    required this.discountController,
    required this.onDiscountChanged,
  });

  final DocumentAmounts amounts;
  final bool showVat;
  final bool pricesIncludeVat;
  final TextEditingController discountController;
  final ValueChanged<double> onDiscountChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalLine(label: 'invoice.items_total'.tr, value: amounts.itemsTotal),
        _discountField(context),
        if (showVat) _TotalLine(label: 'invoice.subtotal'.tr, value: amounts.subtotal),
        if (showVat) _TotalLine(label: 'invoice.vat'.tr, value: amounts.vat),
        const Divider(),
        _TotalLine(label: 'invoice.grand_total'.tr, value: amounts.total, isBig: true),
        if (showVat && pricesIncludeVat)
          Text('invoice.prices_include_vat'.tr, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _discountField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSmall),
      child: Row(
        children: [
          Expanded(child: Text('invoice.discount'.tr, style: Theme.of(context).textTheme.bodyMedium)),
          SizedBox(
            width: AppSizes.monthLabelWidth,
            child: TextField(
              controller: discountController,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: '0.00', isDense: true),
              onChanged: (text) => onDiscountChanged(MoneyUtil.parse(text)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({required this.label, required this.value, this.isBig = false});

  final String label;
  final double value;
  final bool isBig;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = isBig ? textTheme.titleLarge?.copyWith(color: AppColors.primary) : textTheme.titleSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Row(
        children: [
          Expanded(child: Text(label, style: isBig ? textTheme.titleMedium : textTheme.bodyMedium)),
          Text(MoneyUtil.format(value), style: valueStyle),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';

// แถวสินค้าในบิล: ชื่อ + ราคาต่อหน่วย | − จำนวน + | รวม
// กดชื่อ = แก้จำนวน / ราคา / เอาออก (onEdit) / เหลือ 1 ชิ้นแล้วกด − = เอาออกจากบิล
class SellCartRow extends StatelessWidget {
  const SellCartRow({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onEdit,
  });

  final InvoiceDraftItemModel item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSmall),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
                child: _nameAndPrice(context),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSmall),
          _stepper(context),
          SizedBox(
            width: AppSizes.sellLineTotalWidth,
            child: Text(
              MoneyUtil.format(item.amount),
              textAlign: TextAlign.end,
              maxLines: 1,
              style: textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameAndPrice(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final unit = item.unit.isEmpty ? 'sell.unit_default'.tr : item.unit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        Text(
          'sell.unit_price'.trParams({'price': MoneyUtil.format(item.unitPrice), 'unit': unit}),
          style: textTheme.bodySmall,
        ),
        if (item.isOverStock)
          Text(
            'sell.over_stock'.trParams({'stock': '${item.stock}'}),
            style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
          ),
      ],
    );
  }

  Widget _stepper(BuildContext context) {
    final isLast = item.quantity <= 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: isLast ? Icons.delete_outline : Icons.remove,
          tooltip: isLast ? 'sell.remove_item'.tr : 'sell.decrease'.tr,
          color: isLast ? AppColors.danger : AppColors.textPrimary,
          onPressed: isLast ? onRemove : () => onQuantityChanged(item.quantity - 1),
        ),
        SizedBox(
          width: AppSizes.sellStepperValueWidth,
          child: Text('${item.quantity}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
        ),
        _StepButton(
          icon: Icons.add,
          tooltip: 'sell.increase'.tr,
          color: AppColors.primaryDark,
          onPressed: () => onQuantityChanged(item.quantity + 1),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.color, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.sellStepperButton,
      child: IconButton.outlined(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: AppSizes.iconSmall,
        style: IconButton.styleFrom(side: const BorderSide(color: AppColors.border)),
        onPressed: onPressed,
        icon: Icon(icon, color: color),
      ),
    );
  }
}

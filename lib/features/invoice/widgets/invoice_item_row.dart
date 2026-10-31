import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/atoms/money_text.dart';

class InvoiceItemRow extends StatefulWidget {
  const InvoiceItemRow({super.key, required this.item, required this.onChanged, required this.onRemove});

  final InvoiceDraftItemModel item;
  final void Function(int quantity, double unitPrice) onChanged;
  final VoidCallback onRemove;

  @override
  State<InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<InvoiceItemRow> {
  late final _quantityController = TextEditingController(text: widget.item.quantity.toString());
  late final _priceController = TextEditingController(text: widget.item.unitPrice.toString());

  @override
  void didUpdateWidget(InvoiceItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (int.tryParse(_quantityController.text) != widget.item.quantity) {
      _quantityController.text = widget.item.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(int.tryParse(_quantityController.text.trim()) ?? 0, MoneyUtil.parse(_priceController.text));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: widget.item.isOverStock ? AppColors.danger : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(widget.item.name, style: textTheme.titleSmall)),
              Text(
                _stockText(),
                style: textTheme.bodySmall?.copyWith(
                  color: widget.item.isOverStock ? AppColors.danger : AppColors.textSecondary,
                ),
              ),
              IconButton(
                tooltip: 'common.delete'.tr,
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close, color: AppColors.danger),
              ),
            ],
          ),
          _fields(context),
        ],
      ),
    );
  }

  String _stockText() {
    if (!widget.item.trackStock) return 'product.no_stock'.tr;
    return 'invoice.in_stock'.trParams({'stock': '${widget.item.stock}'});
  }

  Widget _fields(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AppTextField(
            label: 'common.quantity'.tr,
            controller: _quantityController,
            keyboardType: TextInputType.number,
            suffixText: widget.item.unit,
            onChanged: (_) => _notifyChanged(),
          ),
        ),
        const SizedBox(width: AppSizes.spaceMedium),
        Expanded(
          child: AppTextField(
            label: 'invoice.unit_price'.tr,
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: 'common.baht'.tr,
            onChanged: (_) => _notifyChanged(),
          ),
        ),
        const SizedBox(width: AppSizes.spaceMedium),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
            child: Align(
              alignment: Alignment.centerRight,
              child: MoneyText(widget.item.amount, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        ),
      ],
    );
  }
}

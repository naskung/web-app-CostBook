import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

// แก้รายการในบิล: พิมพ์จำนวนเยอะ ๆ / ลดราคาเฉพาะชิ้นนี้ / เอาออกจากบิล
class SellItemDialog extends StatefulWidget {
  const SellItemDialog({super.key, required this.item, required this.onSave, required this.onRemove});

  final InvoiceDraftItemModel item;
  final void Function(int quantity, double unitPrice) onSave;
  final VoidCallback onRemove;

  static Future<void> show(
    BuildContext context, {
    required InvoiceDraftItemModel item,
    required void Function(int quantity, double unitPrice) onSave,
    required VoidCallback onRemove,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => SellItemDialog(item: item, onSave: onSave, onRemove: onRemove),
    );
  }

  @override
  State<SellItemDialog> createState() => _SellItemDialogState();
}

class _SellItemDialogState extends State<SellItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _quantityController = TextEditingController(text: '${widget.item.quantity}');
  late final _priceController = TextEditingController(text: MoneyUtil.format(widget.item.unitPrice));

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    widget.onSave(int.tryParse(_quantityController.text.trim()) ?? 1, MoneyUtil.parse(_priceController.text));
    Navigator.pop(context);
  }

  void _onRemove() {
    widget.onRemove();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.item.name,
      subtitle: 'sell.edit_item'.tr,
      icon: Icons.edit_outlined,
      saveLabel: 'common.save'.tr,
      cancelLabel: 'common.cancel'.tr,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'common.quantity'.tr,
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    suffixText: widget.item.unit,
                    validator: ValidatorUtil.positiveInteger,
                    onSubmitted: (_) => _onSave(),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceMedium),
                Expanded(
                  child: AppTextField(
                    label: 'invoice.unit_price'.tr,
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    suffixText: 'common.baht'.tr,
                    validator: ValidatorUtil.zeroOrMore,
                    onSubmitted: (_) => _onSave(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceMedium),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _onRemove,
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                icon: const Icon(Icons.delete_outline),
                label: Text('sell.remove_item'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

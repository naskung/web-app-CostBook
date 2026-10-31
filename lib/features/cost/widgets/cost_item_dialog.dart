import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

class CostItemDialog extends StatefulWidget {
  const CostItemDialog({super.key, required this.type});

  final String type;

  static Future<CostItemModel?> show(BuildContext context, String type) {
    return showDialog<CostItemModel>(context: context, builder: (_) => CostItemDialog(type: type));
  }

  @override
  State<CostItemDialog> createState() => _CostItemDialogState();
}

class _CostItemDialogState extends State<CostItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  late String _type = widget.type;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final item = CostItemModel(
      type: _type,
      name: _nameController.text.trim(),
      amount: MoneyUtil.parse(_amountController.text),
    );
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'cost.item_title'.tr,
      saveLabel: 'common.add'.tr,
      cancelLabel: 'common.cancel'.tr,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown<String>(
              label: 'cost.item_type'.tr,
              value: _type,
              items: {for (final type in CostItemModel.types) type: 'cost.type.$type'.tr},
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(
              label: 'cost.item_name'.tr,
              hint: 'cost.item_name_hint'.tr,
              controller: _nameController,
              validator: ValidatorUtil.required,
            ),
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(
              label: 'common.amount'.tr,
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: ValidatorUtil.positiveNumber,
              suffixText: 'common.baht'.tr,
              onSubmitted: (_) => _onSave(),
            ),
          ],
        ),
      ),
    );
  }
}

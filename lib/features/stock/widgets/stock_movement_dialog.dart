import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

class StockMovementDialog extends StatefulWidget {
  const StockMovementDialog({super.key, required this.type, required this.productId});

  final String type;
  final String productId;

  static Future<void> show(BuildContext context, {required String type, String productId = ''}) {
    final bloc = context.read<StockBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: StockMovementDialog(type: type, productId: productId)),
    );
  }

  @override
  State<StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<StockMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _supplierController = TextEditingController();
  late String _productId = widget.productId;
  bool _isSubmitted = false;

  bool get _isIn => widget.type == MovementModel.stockIn;

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    _unitCostController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    context.read<StockBloc>().add(
      StockMovementSaved(
        type: widget.type,
        productId: _productId,
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        note: _noteController.text.trim(),
        unitCost: _isIn ? MoneyUtil.parse(_unitCostController.text) : 0,
        supplier: _isIn ? _supplierController.text.trim() : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StockBloc, StockState>(
      listenWhen:
          (previous, current) => previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.saveStatus == AppStatus.failure;
        return FormDialog(
          title: _isIn ? 'stock.stock_in_title'.tr : 'stock.stock_out_title'.tr,
          saveLabel: _isIn ? 'stock.stock_in'.tr : 'stock.stock_out'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.saveStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.saveErrorCode}'.tr : '',
          onSave: _onSave,
          child: _form(context, state.items),
        );
      },
    );
  }

  Widget _form(BuildContext context, List<StockItemModel> items) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdown<String>(
            label: 'stock.product'.tr,
            hint: 'stock.choose_product'.tr,
            value: _productId,
            items: {for (final item in items) item.productId: item.name},
            validator: (value) => ValidatorUtil.required(value),
            onChanged: (value) => setState(() => _productId = value ?? ''),
          ),
          _currentStock(context, items),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: 'common.quantity'.tr,
            controller: _quantityController,
            keyboardType: TextInputType.number,
            validator: ValidatorUtil.positiveInteger,
          ),
          if (_isIn) ..._costFields(context),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: 'common.note'.tr,
            hint: 'stock.note_hint'.tr,
            controller: _noteController,
            onSubmitted: (_) => _onSave(),
          ),
        ],
      ),
    );
  }

  List<Widget> _costFields(BuildContext context) {
    return [
      const SizedBox(height: AppSizes.spaceMedium),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              label: 'stock.unit_cost'.tr,
              hint: 'common.optional'.tr,
              controller: _unitCostController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: ValidatorUtil.zeroOrMore,
              suffixText: 'common.baht'.tr,
            ),
          ),
          const SizedBox(width: AppSizes.spaceMedium),
          Expanded(
            child: AppTextField(
              label: 'stock.supplier'.tr,
              hint: 'common.optional'.tr,
              controller: _supplierController,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSizes.spaceSmall),
      Text('stock.unit_cost_hint'.tr, style: Theme.of(context).textTheme.bodySmall),
    ];
  }

  Widget _currentStock(BuildContext context, List<StockItemModel> items) {
    final selected = items.where((item) => item.productId == _productId).toList();
    if (selected.isEmpty) return const SizedBox();
    final item = selected.first;
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spaceSmall),
      child: Text(
        'stock.current'.trParams({'stock': '${item.stock}', 'unit': item.unit}),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

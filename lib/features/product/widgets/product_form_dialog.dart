import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, required this.product});

  final ProductModel product;

  static Future<void> show(BuildContext context, ProductModel product) {
    final bloc = context.read<ProductBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: ProductFormDialog(product: product)),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.product.name);
  late final _unitController = TextEditingController(text: widget.product.unit);
  late final _costController = TextEditingController(text: _numberText(widget.product.costPrice));
  late final _sellController = TextEditingController(text: _numberText(widget.product.sellPrice));
  late final _minStockController = TextEditingController(text: widget.product.minStock.toString());
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  String _numberText(double value) {
    if (value == 0) return '';
    return value.toString();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    final product = ProductModel(
      id: widget.product.id,
      name: _nameController.text.trim(),
      unit: _unitController.text.trim(),
      costPrice: MoneyUtil.parse(_costController.text),
      sellPrice: MoneyUtil.parse(_sellController.text),
      minStock: int.tryParse(_minStockController.text.trim()) ?? 0,
    );
    context.read<ProductBloc>().add(ProductSaved(product));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listenWhen: (previous, current) =>
          previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.saveStatus == AppStatus.failure;
        return FormDialog(
          title: widget.product.isNew ? 'product.add'.tr : 'product.edit'.tr,
          saveLabel: 'common.save'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.saveStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.saveErrorCode}'.tr : '',
          onSave: _onSave,
          child: _form(context),
        );
      },
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'product.name'.tr,
            hint: 'product.name_hint'.tr,
            controller: _nameController,
            validator: ValidatorUtil.required,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(label: 'common.unit'.tr, hint: 'product.unit_hint'.tr, controller: _unitController),
          const SizedBox(height: AppSizes.spaceMedium),
          _priceRow(),
          const SizedBox(height: AppSizes.spaceSmall),
          Text('product.cost_note'.tr, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: 'product.min_stock'.tr,
            hint: 'product.min_stock_hint'.tr,
            controller: _minStockController,
            keyboardType: TextInputType.number,
            validator: ValidatorUtil.zeroOrMore,
          ),
          const SizedBox(height: AppSizes.spaceSmall),
          Text(
            'product.stock_note'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _priceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            label: 'product.cost_price'.tr,
            controller: _costController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: ValidatorUtil.zeroOrMore,
            suffixText: 'common.baht'.tr,
          ),
        ),
        const SizedBox(width: AppSizes.spaceMedium),
        Expanded(
          child: AppTextField(
            label: 'product.sell_price'.tr,
            hint: 'product.sell_price_hint'.tr,
            controller: _sellController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: ValidatorUtil.zeroOrMore,
            suffixText: 'common.baht'.tr,
          ),
        ),
      ],
    );
  }
}

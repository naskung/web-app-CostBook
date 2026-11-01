import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/image_pick_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/custom_field_input.dart';
import 'package:costbook/features/product/widgets/product_image.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_image_box.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, required this.product, required this.fields, required this.categories});

  final ProductModel product;
  final List<ProductFieldModel> fields;
  final List<ProductCategoryModel> categories;

  static Future<void> show(
    BuildContext context,
    ProductModel product,
    List<ProductFieldModel> fields,
    List<ProductCategoryModel> categories,
  ) {
    final bloc = context.read<ProductBloc>();
    return showDialog<void>(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: bloc,
            child: ProductFormDialog(product: product, fields: fields, categories: categories),
          ),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.product.name);
  late final _codeController = TextEditingController(text: widget.product.code);
  // หมวดที่เลือก ('' = ไม่มีหมวด) — หมวดที่ถูกลบไปแล้วถือว่าไม่มีหมวด
  late String _categoryId =
      widget.categories.any((category) => category.id == widget.product.categoryId) ? widget.product.categoryId : '';
  late final _unitController = TextEditingController(text: widget.product.unit);
  late final _costController = TextEditingController(text: _numberText(widget.product.costPrice));
  late final _sellController = TextEditingController(text: _numberText(widget.product.sellPrice));
  late final _minStockController = TextEditingController(text: widget.product.minStock.toString());
  late final _descriptionController = TextEditingController(text: widget.product.description);
  late bool _trackStock = widget.product.trackStock;
  late bool _forSale = widget.product.forSale;
  late final Map<String, String> _customValues = {...widget.product.customFields};
  bool _isSubmitted = false;

  // รูปใหม่ที่เลือก (ยังไม่ได้ส่ง) / กดลบรูปเดิม / error ของรูปก่อนส่ง เช่น ใหญ่เกิน
  Uint8List? _newImage;
  bool _removeImage = false;
  String _imageErrorCode = '';

  bool get _showsImage => _newImage != null || (widget.product.hasImage && !_removeImage);

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _unitController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _numberText(double value) {
    if (value == 0) return '';
    return value.toString();
  }

  void _setCustomValue(String fieldId, String value) {
    _customValues[fieldId] = value;
  }

  Future<void> _pickImage() async {
    final bytes = await ImagePickHelper.pick();
    if (bytes == null) return;
    if (bytes.length > ImagePickHelper.maxBytes) {
      setState(() => _imageErrorCode = 'product_image_too_large');
      return;
    }
    setState(() {
      _newImage = bytes;
      _removeImage = false;
      _imageErrorCode = '';
    });
  }

  void _clearImage() {
    setState(() {
      _newImage = null;
      _removeImage = true;
      _imageErrorCode = '';
    });
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    final product = ProductModel(
      id: widget.product.id,
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      categoryId: _categoryId,
      description: _descriptionController.text.trim(),
      unit: _unitController.text.trim(),
      costPrice: MoneyUtil.parse(_costController.text),
      sellPrice: MoneyUtil.parse(_sellController.text),
      minStock: int.tryParse(_minStockController.text.trim()) ?? 0,
      trackStock: _trackStock,
      forSale: _forSale,
      customFields: Map.fromEntries(_customValues.entries.where((entry) => entry.value.isNotEmpty)),
    );
    context.read<ProductBloc>().add(ProductSaved(product, image: _newImage, removeImage: _removeImage));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listenWhen:
          (previous, current) => previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.saveStatus == AppStatus.failure;
        return FormDialog(
          title: widget.product.isNew ? 'product.add'.tr : 'product.edit'.tr,
          icon: Icons.inventory_2_outlined,
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
          _imageSection(context),
          const SizedBox(height: AppSizes.spaceLarge),
          AppTextField(
            label: 'product.name'.tr,
            hint: 'product.name_hint'.tr,
            controller: _nameController,
            validator: ValidatorUtil.required,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          _twoFields(
            AppTextField(label: 'product.code'.tr, hint: 'product.code_hint'.tr, controller: _codeController),
            AppDropdown<String>(
              label: 'product.category'.tr,
              value: _categoryId,
              items: {
                '': 'product.no_category'.tr,
                for (final category in widget.categories) category.id: category.name,
              },
              onChanged: (value) => setState(() => _categoryId = value ?? ''),
            ),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(label: 'common.unit'.tr, hint: 'product.unit_hint'.tr, controller: _unitController),
          const SizedBox(height: AppSizes.spaceMedium),
          _priceRow(),
          const SizedBox(height: AppSizes.spaceSmall),
          Text('product.cost_note'.tr, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.spaceSmall),
          _stockFields(context),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: 'product.description'.tr,
            hint: 'product.description_hint'.tr,
            controller: _descriptionController,
            maxLines: 2,
          ),
          for (final field in widget.fields) ...[
            const SizedBox(height: AppSizes.spaceMedium),
            CustomFieldInput(
              field: field,
              value: _customValues[field.id] ?? '',
              onChanged: (value) => _setCustomValue(field.id, value),
            ),
          ],
        ],
      ),
    );
  }

  // รูปสินค้า: ตัวอย่างรูป + ปุ่มเลือก / ลบ (ส่งรูปตอนกดบันทึก)
  Widget _imageSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final preview =
        _newImage != null
            ? AppImageBox(bytes: _newImage, width: AppSizes.productImagePreview, height: AppSizes.productImagePreview)
            : ProductImage(
              product: _removeImage ? const ProductModel(name: '') : widget.product,
              width: AppSizes.productImagePreview,
              height: AppSizes.productImagePreview,
            );
    return Row(
      children: [
        preview,
        const SizedBox(width: AppSizes.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('product.image'.tr, style: textTheme.titleSmall),
              const SizedBox(height: AppSizes.spaceXSmall),
              Text('product.image_hint'.tr, style: textTheme.bodySmall),
              const SizedBox(height: AppSizes.spaceSmall),
              Wrap(
                spacing: AppSizes.spaceSmall,
                runSpacing: AppSizes.spaceXSmall,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(_showsImage ? 'product.image_change'.tr : 'product.image_pick'.tr),
                  ),
                  if (_showsImage)
                    TextButton.icon(
                      onPressed: _clearImage,
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      icon: const Icon(Icons.delete_outline),
                      label: Text('product.image_remove'.tr),
                    ),
                ],
              ),
              if (_imageErrorCode.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceXSmall),
                Text('error.$_imageErrorCode'.tr, style: textTheme.bodySmall?.copyWith(color: AppColors.danger)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _twoFields(Widget first, Widget second) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: first), const SizedBox(width: AppSizes.spaceMedium), Expanded(child: second)],
    );
  }

  Widget _priceRow() {
    return _twoFields(
      AppTextField(
        label: 'product.cost_price'.tr,
        controller: _costController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: ValidatorUtil.zeroOrMore,
        suffixText: 'common.baht'.tr,
      ),
      AppTextField(
        label: 'product.sell_price'.tr,
        controller: _sellController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: ValidatorUtil.zeroOrMore,
        suffixText: 'common.baht'.tr,
      ),
    );
  }

  Widget _stockFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('product.for_sale'.tr),
          subtitle: Text(_forSale ? 'product.for_sale_on'.tr : 'product.for_sale_off'.tr),
          value: _forSale,
          onChanged: (value) => setState(() => _forSale = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('product.track_stock'.tr),
          subtitle: Text(_trackStock ? 'product.stock_note'.tr : 'product.track_stock_off'.tr),
          value: _trackStock,
          onChanged: (value) => setState(() => _trackStock = value),
        ),
        const SizedBox(height: AppSizes.spaceSmall),
        if (_trackStock)
          AppTextField(
            label: 'product.min_stock'.tr,
            hint: 'product.min_stock_hint'.tr,
            controller: _minStockController,
            keyboardType: TextInputType.number,
            validator: ValidatorUtil.zeroOrMore,
          ),
        if (!_trackStock)
          Text(
            'product.track_stock_off_note'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/cost_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

class CostItemDialogResult {
  const CostItemDialogResult({required this.item, required this.remember});

  final CostItemModel item;
  final bool remember;
}

// forPreset = true → ใช้เพิ่ม / แก้รายการที่ใช้บ่อย (ไม่มีช่องจำนวน ไม่มีปุ่มเลือกจากรายการที่ใช้บ่อย)
class CostItemDialog extends StatefulWidget {
  const CostItemDialog({
    super.key,
    required this.item,
    required this.presets,
    this.materials = const [],
    this.forPreset = false,
  });

  final CostItemModel item;
  final List<CostPresetModel> presets;
  // วัสดุในสต็อกที่เลือกผูกกับบรรทัดนี้ได้ (สินค้าที่ไม่ขาย)
  final List<ProductModel> materials;
  final bool forPreset;

  static Future<CostItemDialogResult?> show(
    BuildContext context, {
    required CostItemModel item,
    required List<CostPresetModel> presets,
    List<ProductModel> materials = const [],
    bool forPreset = false,
  }) {
    return showDialog<CostItemDialogResult>(
      context: context,
      builder: (_) => CostItemDialog(item: item, presets: presets, materials: materials, forPreset: forPreset),
    );
  }

  @override
  State<CostItemDialog> createState() => _CostItemDialogState();
}

class _CostItemDialogState extends State<CostItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.item.name);
  late final _quantityController = TextEditingController(text: _numberText(widget.item.quantity));
  late final _unitController = TextEditingController(text: widget.item.unit);
  late final _unitPriceController = TextEditingController(text: _numberText(widget.item.unitPrice));
  late final _percentController = TextEditingController(text: _numberText(widget.item.percent));
  late String _type = widget.item.type;
  late String _kind = widget.item.kind;
  late String _materialId = widget.item.materialId;
  bool _remember = false;

  bool get _isNew => widget.item.name.isEmpty;

  bool get _isPercent => _kind == CostItemModel.percentKind;

  bool get _usesMaterial => _materialId.isNotEmpty && !_isPercent;

  bool get _canPickMaterial => !widget.forPreset && widget.materials.isNotEmpty && !_isPercent;

  // เลือกวัสดุ → ชื่อ / หน่วย / ราคาต่อหน่วยมาจากวัสดุ (ราคาอัปเดตเองเมื่อราคาวัสดุเปลี่ยน)
  void _applyMaterial(String? materialId) {
    final picked = widget.materials.where((material) => material.id == materialId).toList();
    setState(() {
      _materialId = picked.isEmpty ? '' : picked.first.id;
      if (picked.isEmpty) return;
      _type = CostItemModel.material;
      _nameController.text = picked.first.name;
      _unitController.text = picked.first.unit;
      _unitPriceController.text = _numberText(picked.first.costPrice);
    });
  }

  String _materialLabel(ProductModel material) {
    final unit = material.unit.isEmpty ? '' : ' / ${material.unit}';
    return '${material.name} (${MoneyUtil.format(material.costPrice)}$unit · ${'cost.material_left'.trParams({'stock': '${material.stock}', 'unit': material.unit})})';
  }

  String get _title {
    if (widget.forPreset) return _isNew ? 'cost.preset_add_title'.tr : 'cost.preset_edit_title'.tr;
    return _isNew ? 'cost.item_title'.tr : 'cost.item_edit_title'.tr;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  String _numberText(double value) {
    if (value == 0) return '';
    return value.toString();
  }

  void _applyPreset(String? presetId) {
    final presets = widget.presets.where((preset) => preset.id == presetId).toList();
    if (presets.isEmpty) return;
    final preset = presets.first;
    setState(() {
      _type = preset.type;
      _kind = preset.kind;
      _nameController.text = preset.name;
      _unitController.text = preset.unit;
      _unitPriceController.text = _numberText(preset.unitPrice);
      _percentController.text = _numberText(preset.percent);
    });
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final item = CostItemModel(
      materialId: _usesMaterial ? _materialId : '',
      type: _type,
      kind: _kind,
      name: _nameController.text.trim(),
      quantity: _isPercent || widget.forPreset ? 1 : MoneyUtil.parse(_quantityController.text),
      unit: _isPercent ? '' : _unitController.text.trim(),
      unitPrice: _isPercent ? 0 : MoneyUtil.parse(_unitPriceController.text),
      percent: _isPercent ? MoneyUtil.parse(_percentController.text) : 0,
    );
    Navigator.pop(context, CostItemDialogResult(item: item, remember: _remember));
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: _title,
      icon: widget.forPreset ? Icons.bookmark_border : Icons.calculate_outlined,
      saveLabel: _isNew ? 'common.add'.tr : 'common.save'.tr,
      cancelLabel: 'common.cancel'.tr,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isNew && !widget.forPreset && widget.presets.isNotEmpty) ...[
              AppDropdown<String>(
                label: 'cost.from_preset'.tr,
                hint: 'cost.choose_preset'.tr,
                value: null,
                items: {for (final preset in widget.presets) preset.id: preset.name},
                onChanged: _applyPreset,
              ),
              const SizedBox(height: AppSizes.spaceMedium),
            ],
            if (_canPickMaterial) ...[
              AppDropdown<String>(
                label: 'cost.material'.tr,
                value: _materialId,
                items: {
                  '': 'cost.no_material'.tr,
                  for (final material in widget.materials) material.id: _materialLabel(material),
                },
                onChanged: _applyMaterial,
              ),
              if (_usesMaterial) ...[
                const SizedBox(height: AppSizes.spaceXSmall),
                Text('cost.material_hint'.tr, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: AppSizes.spaceMedium),
            ],
            AppDropdown<String>(
              label: 'cost.item_type'.tr,
              value: _type,
              items: {for (final type in CostItemModel.types) type: 'cost.type.$type'.tr},
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: AppSizes.spaceMedium),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: CostItemModel.fixed, label: Text('cost.kind_fixed'.tr)),
                ButtonSegment(value: CostItemModel.percentKind, label: Text('cost.kind_percent'.tr)),
              ],
              selected: {_kind},
              onSelectionChanged: (selected) => setState(() => _kind = selected.first),
            ),
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(
              label: 'cost.item_name'.tr,
              hint: _isPercent ? 'cost.item_name_percent_hint'.tr : 'cost.item_name_hint'.tr,
              controller: _nameController,
              validator: ValidatorUtil.required,
            ),
            const SizedBox(height: AppSizes.spaceMedium),
            if (_isPercent) _percentField() else _fixedFields(context),
            if (_isNew && !widget.forPreset)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('cost.remember'.tr),
                value: _remember,
                onChanged: (value) => setState(() => _remember = value ?? false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _percentField() {
    return AppTextField(
      label: 'cost.percent'.tr,
      hint: 'cost.percent_hint'.tr,
      controller: _percentController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: ValidatorUtil.positiveNumber,
      suffixText: '%',
    );
  }

  Widget _unitField() {
    return AppTextField(
      label: 'common.unit'.tr,
      hint: 'cost.unit_hint'.tr,
      controller: _unitController,
      readOnly: _usesMaterial,
    );
  }

  Widget _unitPriceField() {
    return AppTextField(
      label: 'cost.unit_price'.tr,
      controller: _unitPriceController,
      readOnly: _usesMaterial,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: ValidatorUtil.zeroOrMore,
      suffixText: 'common.baht'.tr,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _fixedFields(BuildContext context) {
    if (widget.forPreset) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _unitField()),
          const SizedBox(width: AppSizes.spaceMedium),
          Expanded(child: _unitPriceField()),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'common.quantity'.tr,
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: ValidatorUtil.positiveNumber,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppSizes.spaceMedium),
            Expanded(child: _unitField()),
          ],
        ),
        const SizedBox(height: AppSizes.spaceMedium),
        _unitPriceField(),
        const SizedBox(height: AppSizes.spaceSmall),
        Text(
          'cost.line_result'.trParams({
            'amount': MoneyUtil.format(
              CostUtil.lineAmount(
                quantity: MoneyUtil.parse(_quantityController.text),
                unitPrice: MoneyUtil.parse(_unitPriceController.text),
              ),
            ),
          }),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

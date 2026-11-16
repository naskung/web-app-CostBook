import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/cost_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/molecules/app_tabs.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

// รับเข้า / เบิกออก อยู่ใน dialog เดียว สลับด้วยแท็บด้านบน (type = แท็บที่เปิดมาก่อน)
class StockMovementDialog extends StatefulWidget {
  const StockMovementDialog({super.key, required this.type, required this.productId});

  final String type;
  final String productId;

  static Future<void> show(BuildContext context, {String type = MovementModel.stockIn, String productId = ''}) {
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
  final _costController = TextEditingController();
  final _supplierController = TextEditingController();
  late String _productId = widget.productId;
  late String _type = widget.type;
  bool _isSubmitted = false;
  // รับเข้า = ผลิตเสร็จ → ตัดวัสดุตามใบต้นทุน (ปิดได้ถ้าเป็นของที่ทำไว้ก่อน)
  bool _useMaterials = true;
  // ราคาทุนตอนรับเข้า: true = ใส่ราคารวมที่จ่าย (ระบบหารจำนวนให้) / false = ใส่ราคาต่อหน่วยเอง
  bool _isTotalCost = true;

  bool get _isIn => _type == MovementModel.stockIn;

  int get _quantity => int.tryParse(_quantityController.text.trim()) ?? 0;

  // ราคาทุนต่อหน่วยที่ส่งไป — ใส่ราคารวม → หารด้วยจำนวนที่รับเข้า
  double get _unitCost {
    final cost = MoneyUtil.parse(_costController.text);
    if (!_isTotalCost) return cost;
    return CostUtil.perUnit(total: cost, quantity: _quantity.toDouble());
  }

  // เปลี่ยนแท็บ: สินค้า / จำนวน / หมายเหตุที่กรอกไว้ยังอยู่ / ซ่อน error ของแท็บเดิม
  void _setType(String type) {
    setState(() {
      _type = type;
      _isSubmitted = false;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    context.read<StockBloc>().add(
      StockMovementSaved(
        type: _type,
        productId: _productId,
        quantity: _quantity,
        note: _noteController.text.trim(),
        unitCost: _isIn ? _unitCost : 0,
        supplier: _isIn ? _supplierController.text.trim() : '',
        skipMaterials: _isIn && !_useMaterials,
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
          icon: _isIn ? Icons.move_to_inbox_outlined : Icons.outbox_outlined,
          saveLabel: _isIn ? 'stock.stock_in'.tr : 'stock.stock_out'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.saveStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.saveErrorCode}'.trParams(state.saveErrorParams) : '',
          onSave: _onSave,
          tabs: _tabs(),
          child: _form(context, state.items),
        );
      },
    );
  }

  Widget _tabs() {
    return AppTabs(
      selected: _type,
      selectedColor: AppColors.surface,
      onChanged: _setType,
      tabs: [
        AppTab(value: MovementModel.stockIn, label: 'stock.stock_in'.tr, icon: Icons.move_to_inbox_outlined),
        AppTab(value: MovementModel.stockOut, label: 'stock.stock_out'.tr, icon: Icons.outbox_outlined),
      ],
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
            onChanged: (_) => setState(() {}),
          ),
          if (_isIn) ..._costFields(context, items),
          if (_isIn)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text('stock.use_materials'.tr),
              subtitle: Text('stock.use_materials_hint'.tr),
              value: _useMaterials,
              onChanged: (value) => setState(() => _useMaterials = value ?? true),
            ),
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

  List<Widget> _costFields(BuildContext context, List<StockItemModel> items) {
    return [
      const SizedBox(height: AppSizes.spaceMedium),
      Align(
        alignment: Alignment.centerLeft,
        child: SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text('stock.cost_mode_total'.tr)),
            ButtonSegment(value: false, label: Text('stock.cost_mode_unit'.tr)),
          ],
          selected: {_isTotalCost},
          onSelectionChanged: (selected) => setState(() => _isTotalCost = selected.first),
        ),
      ),
      const SizedBox(height: AppSizes.spaceMedium),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              label: _isTotalCost ? 'stock.total_cost'.tr : 'stock.unit_cost'.tr,
              hint: 'common.optional'.tr,
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: ValidatorUtil.zeroOrMore,
              suffixText: 'common.baht'.tr,
              onChanged: (_) => setState(() {}),
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
      if (_isTotalCost && _unitCost > 0) ...[
        const SizedBox(height: AppSizes.spaceSmall),
        Text(
          'stock.total_cost_result'.trParams({'cost': MoneyUtil.format(_unitCost), 'unit': _unitOf(items)}),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
        ),
      ],
      const SizedBox(height: AppSizes.spaceSmall),
      Text('stock.unit_cost_hint'.tr, style: Theme.of(context).textTheme.bodySmall),
    ];
  }

  String _unitOf(List<StockItemModel> items) {
    for (final item in items) {
      if (item.productId == _productId && item.unit.isNotEmpty) return item.unit;
    }
    return 'common.unit'.tr;
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

import 'package:flutter/material.dart';

import 'package:costbook/core/constants/product_form_block.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';

// หน้าตาของ 1 ช่องในฟอร์มเพิ่ม / แก้สินค้า (กรอกไม่ได้ ไว้ดูตอนจัดตำแหน่ง)
class FormBlockPreview extends StatelessWidget {
  const FormBlockPreview({super.key, required this.blockKey, this.field});

  final String blockKey;
  final ProductFieldModel? field;

  @override
  Widget build(BuildContext context) {
    final field = this.field;
    if (field != null) return MockInput(label: field.name, hint: _fieldHint(field), icon: _fieldIcon(field));
    return switch (blockKey) {
      ProductFormBlock.image => const _MockImage(),
      ProductFormBlock.name => MockInput(label: 'product.name'.tr, hint: 'product.name_hint'.tr),
      ProductFormBlock.codeCategory => _MockPair(
        first: MockInput(label: 'product.code'.tr, hint: 'product.code_hint'.tr),
        second: MockInput(label: 'product.category'.tr, hint: 'product.no_category'.tr, icon: Icons.arrow_drop_down),
      ),
      ProductFormBlock.unit => MockInput(label: 'common.unit'.tr, hint: 'product.unit_hint'.tr),
      ProductFormBlock.prices => _MockPair(
        first: MockInput(label: 'product.cost_price'.tr, hint: '0.00', suffix: 'common.baht'.tr),
        second: MockInput(label: 'product.sell_price'.tr, hint: '0.00', suffix: 'common.baht'.tr),
      ),
      ProductFormBlock.saleStock => const _MockSaleStock(),
      ProductFormBlock.description => MockInput(
        label: 'product.description'.tr,
        hint: 'product.description_hint'.tr,
        height: AppSizes.mockTextAreaHeight,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  String _fieldHint(ProductFieldModel field) {
    return switch (field.type) {
      ProductFieldModel.select => field.options.join(' / '),
      ProductFieldModel.number => '0',
      ProductFieldModel.date => 'settings.form_preview_date'.tr,
      _ => 'settings.field_type.${field.type}'.tr,
    };
  }

  IconData? _fieldIcon(ProductFieldModel field) {
    if (field.type == ProductFieldModel.select) return Icons.arrow_drop_down;
    if (field.type == ProductFieldModel.date) return Icons.calendar_today_outlined;
    return null;
  }
}

class MockInput extends StatelessWidget {
  const MockInput({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.suffix = '',
    this.height = AppSizes.mockInputHeight,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final String suffix;
  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = this.icon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSizes.spaceXSmall),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSmall + AppSizes.spaceXSmall),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textDisabled),
                ),
              ),
              if (suffix.isNotEmpty) Text(suffix, style: textTheme.bodySmall),
              if (icon != null) Icon(icon, size: AppSizes.iconSmall, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _MockPair extends StatelessWidget {
  const _MockPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: first), const SizedBox(width: AppSizes.spaceSmall), Expanded(child: second)],
    );
  }
}

class _MockImage extends StatelessWidget {
  const _MockImage();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: AppSizes.mockImageSize,
          height: AppSizes.mockImageSize,
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSizes.spaceSmall + AppSizes.spaceXSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('product.image'.tr, style: textTheme.titleSmall),
              Text('product.image_hint'.tr, style: textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _MockSaleStock extends StatelessWidget {
  const _MockSaleStock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _switchRow(context, 'product.for_sale'.tr),
        _switchRow(context, 'product.track_stock'.tr),
        const SizedBox(height: AppSizes.spaceXSmall),
        MockInput(label: 'product.min_stock'.tr, hint: 'product.min_stock_hint'.tr),
      ],
    );
  }

  Widget _switchRow(BuildContext context, String label) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        const Icon(Icons.toggle_on, color: AppColors.primary, size: AppSizes.iconBox * 0.75),
      ],
    );
  }
}

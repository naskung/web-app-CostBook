import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/settings/widgets/form_block_preview.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';

// 1 ช่องในหน้าจัดฟอร์ม: ที่จับลาก ⠿ + หน้าตาช่องจริง + (ช่องที่ร้านเพิ่ม) ปุ่มแก้ / ลบ
class FormLayoutCard extends StatelessWidget {
  const FormLayoutCard({
    super.key,
    required this.index,
    required this.blockKey,
    this.field,
    this.onEdit,
    this.onDelete,
  });

  final int index;
  final String blockKey;
  final ProductFieldModel? field;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, AppSizes.spaceSmall, AppSizes.spaceSmall, AppSizes.spaceMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _badges(),
                    const SizedBox(height: AppSizes.spaceSmall),
                    FormBlockPreview(blockKey: blockKey, field: field),
                  ],
                ),
              ),
              if (field != null) _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return ReorderableDragStartListener(
      index: index,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Tooltip(
          message: 'settings.form_layout_drag'.tr,
          child: const SizedBox(
            width: AppSizes.dragHandleWidth,
            height: AppSizes.buttonHeight,
            child: Icon(Icons.drag_indicator, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _badges() {
    final field = this.field;
    return Wrap(
      spacing: AppSizes.spaceXSmall,
      runSpacing: AppSizes.spaceXSmall,
      children: [
        if (field == null)
          AppBadge(
            text: 'settings.form_block_badge'.tr,
            color: AppColors.textSecondary,
            backgroundColor: AppColors.neutralSoft,
          )
        else
          AppBadge(
            text: 'settings.form_field_badge'.tr,
            color: AppColors.primaryDark,
            backgroundColor: AppColors.primarySoft,
          ),
        if (field != null && field.showInList)
          AppBadge(
            text: 'settings.field_in_list'.tr,
            color: AppColors.textPrimary,
            backgroundColor: AppColors.neutralSoft,
          ),
      ],
    );
  }

  Widget _actions() {
    return Column(
      children: [
        IconButton(tooltip: 'common.edit'.tr, onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        IconButton(
          tooltip: 'common.delete'.tr,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
        ),
      ],
    );
  }
}

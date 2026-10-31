import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/cost/bloc/cost_bloc.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/features/cost/widgets/cost_item_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';
import 'package:costbook/shared/widgets/organisms/app_dialog.dart';

// จัดการรายการต้นทุนที่ใช้บ่อย: เพิ่ม / แก้ / ลบ (แยกกล่องตามประเภท)
class CostPresetsDialog extends StatelessWidget {
  const CostPresetsDialog({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<CostBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: const CostPresetsDialog()),
    );
  }

  Future<void> _add(BuildContext context) async {
    final bloc = context.read<CostBloc>();
    final result = await CostItemDialog.show(
      context,
      item: const CostItemModel(type: CostItemModel.material, name: ''),
      presets: const [],
      forPreset: true,
    );
    if (result != null) bloc.add(CostPresetSaved(CostPresetModel.fromItem(result.item)));
  }

  Future<void> _edit(BuildContext context, CostPresetModel preset) async {
    final bloc = context.read<CostBloc>();
    final result = await CostItemDialog.show(context, item: preset.toItem(), presets: const [], forPreset: true);
    if (result != null) bloc.add(CostPresetSaved(CostPresetModel.fromItem(result.item, id: preset.id)));
  }

  Future<void> _delete(BuildContext context, CostPresetModel preset) async {
    final bloc = context.read<CostBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'cost.preset_delete_title'.tr,
      message: 'cost.preset_delete_message'.trParams({'name': preset.name}),
      confirmText: 'common.delete'.tr,
    );
    if (isConfirmed) bloc.add(CostPresetDeleted(preset.id));
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'cost.presets_title'.tr,
      subtitle: 'cost.presets_hint'.tr,
      icon: Icons.bookmarks_outlined,
      closeLabel: 'common.close'.tr,
      actions: [
        AppButton(
          text: 'common.close'.tr,
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(text: 'cost.preset_add'.tr, icon: Icons.add, onPressed: () => _add(context)),
      ],
      child: BlocBuilder<CostBloc, CostState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.presetErrorCode.isNotEmpty) ...[
                NoticeBanner(message: 'error.${state.presetErrorCode}'.tr),
                const SizedBox(height: AppSizes.spaceMedium),
              ],
              if (state.presets.isEmpty) EmptyView(message: 'cost.presets_empty'.tr, icon: Icons.bookmark_border),
              for (final type in CostItemModel.types) ..._typeGroup(context, state.presets, type),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _typeGroup(BuildContext context, List<CostPresetModel> presets, String type) {
    final items = presets.where((preset) => preset.type == type).toList();
    if (items.isEmpty) return [];
    return [
      Row(
        children: [
          Text('cost.type.$type'.tr, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: AppSizes.spaceSmall),
          AppBadge(text: '${items.length}', color: AppColors.textSecondary, backgroundColor: AppColors.neutralSoft),
        ],
      ),
      const SizedBox(height: AppSizes.spaceSmall),
      DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: AppSizes.borderWidth, color: AppColors.border),
              _presetRow(context, items[i]),
            ],
          ],
        ),
      ),
      const SizedBox(height: AppSizes.spaceLarge),
    ];
  }

  Widget _presetRow(BuildContext context, CostPresetModel preset) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceMedium,
        AppSizes.spaceSmall,
        AppSizes.spaceXSmall,
        AppSizes.spaceSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preset.name, style: textTheme.bodyMedium),
                const SizedBox(height: AppSizes.spaceXSmall),
                Text(_detail(preset), style: textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'common.edit'.tr,
            onPressed: () => _edit(context, preset),
            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: AppSizes.iconSmall),
          ),
          IconButton(
            tooltip: 'common.delete'.tr,
            onPressed: () => _delete(context, preset),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: AppSizes.iconSmall),
          ),
        ],
      ),
    );
  }

  String _detail(CostPresetModel preset) {
    if (preset.kind == CostItemModel.percentKind) return '${MoneyUtil.format(preset.percent)}%';
    final unit = preset.unit.isEmpty ? '' : ' / ${preset.unit}';
    return '${MoneyUtil.format(preset.unitPrice)} ${'common.baht'.tr}$unit';
  }
}

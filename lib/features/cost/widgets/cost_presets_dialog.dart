import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/cost/bloc/cost_bloc.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';

class CostPresetsDialog extends StatelessWidget {
  const CostPresetsDialog({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<CostBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: const CostPresetsDialog()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('cost.presets_title'.tr),
      content: SizedBox(
        width: AppSizes.dialogMaxWidth,
        child: BlocBuilder<CostBloc, CostState>(
          builder: (context, state) {
            if (state.presets.isEmpty) return EmptyView(message: 'cost.presets_empty'.tr, icon: Icons.bookmark_border);
            return ListView(
              shrinkWrap: true,
              children: [for (final preset in state.presets) _presetRow(context, preset)],
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('common.close'.tr))],
    );
  }

  Widget _presetRow(BuildContext context, CostPresetModel preset) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(preset.name),
      subtitle: Text('${'cost.type.${preset.type}'.tr} · ${_detail(preset)}'),
      trailing: IconButton(
        tooltip: 'common.delete'.tr,
        onPressed: () => context.read<CostBloc>().add(CostPresetDeleted(preset.id)),
        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
    );
  }

  String _detail(CostPresetModel preset) {
    if (preset.kind == 'percent') return '${MoneyUtil.format(preset.percent)}%';
    final unit = preset.unit.isEmpty ? '' : ' / ${preset.unit}';
    return '${MoneyUtil.format(preset.unitPrice)} ${'common.baht'.tr}$unit';
  }
}

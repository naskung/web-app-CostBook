import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/assistant/models/ai_action_model.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';

class AiActionCard extends StatelessWidget {
  const AiActionCard({super.key, required this.action, required this.onConfirm, required this.onCancel});

  static const List<String> _moneyFields = ['sell_price', 'cost_price'];

  final AiActionModel action;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.spaceSmall),
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_icon(), color: AppColors.primary, size: AppSizes.iconSmall),
              const SizedBox(width: AppSizes.spaceSmall),
              Expanded(child: Text(_title(), style: textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: AppSizes.spaceXSmall),
          for (final line in _details()) Text(line, style: textTheme.bodyMedium),
          if (action.reason.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceXSmall),
            Text(
              'assistant.reason'.trParams({'reason': action.reason}),
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSizes.spaceSmall),
          _status(context),
        ],
      ),
    );
  }

  IconData _icon() {
    switch (action.type) {
      case AiActionModel.createProduct:
        return Icons.add_box_outlined;
      case AiActionModel.updateProduct:
        return Icons.edit_outlined;
      case AiActionModel.stockIn:
        return Icons.south_west;
      case AiActionModel.stockOut:
        return Icons.north_east;
      case AiActionModel.addTransaction:
        return Icons.account_balance_wallet_outlined;
      case AiActionModel.marketCheck:
        return Icons.travel_explore;
    }
    return Icons.task_alt;
  }

  String _title() {
    final name = action.productName.isEmpty ? '' : ': ${action.productName}';
    return '${'assistant.action.${action.type}'.tr}$name';
  }

  String _value(String field, String value) {
    if (!_moneyFields.contains(field)) return value;
    return MoneyUtil.format(double.tryParse(value) ?? 0);
  }

  List<String> _details() {
    switch (action.type) {
      case AiActionModel.createProduct:
        return [
          'assistant.detail.price'.trParams({
            'price': MoneyUtil.format(action.dataNumber('sell_price')),
            'unit': action.dataText('unit'),
          }),
          if (action.dataText('category').isNotEmpty)
            'assistant.detail.category'.trParams({'category': action.dataText('category')}),
          if (action.dataNumber('cost_price') > 0)
            'assistant.detail.cost'.trParams({'cost': MoneyUtil.format(action.dataNumber('cost_price'))}),
        ];
      case AiActionModel.updateProduct:
        return [
          for (final change in action.changes)
            'assistant.detail.change'.trParams({
              'field': 'assistant.field.${change.field}'.tr,
              'from': _value(change.field, change.from),
              'to': _value(change.field, change.to),
            }),
        ];
      case AiActionModel.stockIn:
      case AiActionModel.stockOut:
        return [
          'assistant.detail.quantity'.trParams({'quantity': '${action.dataNumber('quantity').toInt()}'}),
          if (action.dataNumber('unit_cost') > 0)
            'assistant.detail.unit_cost'.trParams({'cost': MoneyUtil.format(action.dataNumber('unit_cost'))}),
          if (action.dataText('supplier').isNotEmpty)
            'assistant.detail.supplier'.trParams({'supplier': action.dataText('supplier')}),
          if (action.dataText('note').isNotEmpty) action.dataText('note'),
        ];
      case AiActionModel.addTransaction:
        return [
          '${'transaction.${action.dataText('type')}'.tr} · ${'transaction.category.${action.dataText('category')}'.tr}',
          'assistant.detail.amount'.trParams({
            'amount': MoneyUtil.format(action.dataNumber('amount')),
            'date': action.dataText('date'),
          }),
          if (action.dataText('note').isNotEmpty) action.dataText('note'),
        ];
      case AiActionModel.marketCheck:
        return ['assistant.detail.market_check'.tr];
    }
    return [];
  }

  Widget _status(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (action.status) {
      case AiActionModel.pending:
        return Wrap(
          spacing: AppSizes.spaceSmall,
          children: [
            FilledButton.icon(onPressed: onConfirm, icon: const Icon(Icons.check), label: Text('assistant.confirm'.tr)),
            OutlinedButton(onPressed: onCancel, child: Text('assistant.decline'.tr)),
          ],
        );
      case AiActionModel.running:
        return Row(
          children: [
            const AppLoading(),
            const SizedBox(width: AppSizes.spaceSmall),
            Text(action.type == AiActionModel.marketCheck ? 'market.checking'.tr : 'assistant.running'.tr),
          ],
        );
      case AiActionModel.done:
        return _result(textTheme, Icons.check_circle, AppColors.success, 'assistant.done'.tr);
      case AiActionModel.failed:
        return _result(textTheme, Icons.error_outline, AppColors.danger, 'error.${action.errorCode}'.tr);
    }
    return _result(textTheme, Icons.block, AppColors.textSecondary, 'assistant.declined'.tr);
  }

  Widget _result(TextTheme textTheme, IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppSizes.iconSmall),
        const SizedBox(width: AppSizes.spaceXSmall),
        Expanded(child: Text(text, style: textTheme.bodyMedium?.copyWith(color: color))),
      ],
    );
  }
}

part of 'stock_page.dart';

extension _StockPageExt on StockPage {
  Widget _toolbar(BuildContext context) {
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockIn),
          icon: const Icon(Icons.add),
          label: Text('stock.stock_in'.tr),
        ),
        OutlinedButton.icon(
          onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockOut),
          icon: const Icon(Icons.remove),
          label: Text('stock.stock_out'.tr),
        ),
      ],
      children: [Text('stock.history_subtitle'.tr, style: Theme.of(context).textTheme.bodySmall)],
    );
  }

  Widget? _stateView(BuildContext context, StockState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<StockBloc>().add(StockRequested()),
      );
    }
    if (state.movements.isEmpty) return EmptyView(message: 'stock.history_empty'.tr, icon: Icons.history);
    return null;
  }

  Widget _history(BuildContext context, List<MovementModel> movements) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'stock.history_time'.tr, flex: 2),
        AppDataColumn(label: 'stock.product'.tr, flex: 3),
        AppDataColumn(label: 'stock.type'.tr, flex: 2),
        AppDataColumn(label: 'common.quantity'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'common.note'.tr, flex: 3),
      ],
      rows: [
        for (final movement in movements)
          [
            Text(_timeText(movement.createdAt)),
            Text(movement.productName),
            _typeBadge(movement),
            Text(
              '${movement.isIn ? '+' : '-'}${movement.quantity} ${movement.unit}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: movement.isIn ? AppColors.success : AppColors.danger),
            ),
            Text(_noteText(movement), style: Theme.of(context).textTheme.bodySmall),
          ],
      ],
    );
  }

  Widget _typeBadge(MovementModel movement) {
    if (movement.isIn) {
      return AppBadge(text: 'stock.stock_in'.tr, color: AppColors.success, backgroundColor: AppColors.successSoft);
    }
    return AppBadge(text: 'stock.stock_out'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft);
  }

  String _timeText(DateTime time) {
    final minute = time.minute.toString().padLeft(2, '0');
    return '${DateUtil.toDisplayDate(time)} ${time.hour}:$minute';
  }

  String _noteText(MovementModel movement) {
    if (!movement.isFromInvoice) {
      final parts = [
        if (movement.unitCost > 0) 'stock.cost_detail'.trParams({'cost': MoneyUtil.format(movement.unitCost)}),
        if (movement.supplier.isNotEmpty) movement.supplier,
        if (movement.note.isNotEmpty) movement.note,
      ];
      return parts.join(' · ');
    }
    if (movement.isIn) return 'stock.from_invoice_in'.trParams({'no': movement.invoiceNo});
    return 'stock.from_invoice_out'.trParams({'no': movement.invoiceNo});
  }
}

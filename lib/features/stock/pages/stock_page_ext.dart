part of 'stock_page.dart';

extension _StockPageExt on StockPage {
  Widget _toolbar(BuildContext context, StockState state) {
    final bloc = context.read<StockBloc>();
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
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text('stock.view_stock'.tr), icon: const Icon(Icons.inventory_2_outlined)),
            ButtonSegment(value: true, label: Text('stock.view_history'.tr), icon: const Icon(Icons.history)),
          ],
          selected: {state.showHistory},
          onSelectionChanged: (selected) => bloc.add(StockViewChanged(showHistory: selected.first)),
        ),
        if (!state.showHistory)
          FilterChip(
            label: Text('stock.only_low'.tr),
            selected: state.onlyLow,
            onSelected: (selected) => bloc.add(StockFilterChanged(onlyLow: selected)),
          ),
      ],
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
    if (state.showHistory && state.movements.isEmpty) {
      return EmptyView(message: 'stock.history_empty'.tr, icon: Icons.history);
    }
    if (state.showHistory) return null;
    if (state.items.isEmpty) return EmptyView(message: 'stock.empty'.tr, icon: Icons.warehouse_outlined);
    if (state.visibleItems.isEmpty) return EmptyView(message: 'stock.low_empty'.tr, icon: Icons.check_circle_outline);
    return null;
  }

  Widget _content(BuildContext context, StockState state) {
    if (state.showHistory) return _history(context, state.movements);
    return _stockTable(context, state.visibleItems);
  }

  Widget _stockTable(BuildContext context, List<StockItemModel> items) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'stock.product'.tr, flex: 3),
        AppDataColumn(label: 'product.stock'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'stock.min_stock'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'stock.status'.tr, flex: 2, alignEnd: true),
        const AppDataColumn(label: '', flex: 2, alignEnd: true),
      ],
      rows: [
        for (final item in items)
          [
            Text(item.name, style: Theme.of(context).textTheme.titleSmall),
            Text('${item.stock} ${item.unit}', style: Theme.of(context).textTheme.titleSmall),
            Text('${item.minStock}'),
            _statusBadge(item),
            _rowActions(context, item),
          ],
      ],
    );
  }

  Widget _statusBadge(StockItemModel item) {
    if (item.isOut) {
      return AppBadge(text: 'stock.status_out'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft);
    }
    if (item.isLow) {
      return AppBadge(text: 'stock.status_low'.tr, color: AppColors.textPrimary, backgroundColor: AppColors.warningSoft);
    }
    return AppBadge(text: 'stock.status_ok'.tr, color: AppColors.success, backgroundColor: AppColors.successSoft);
  }

  Widget _rowActions(BuildContext context, StockItemModel item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'stock.stock_in'.tr,
          onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockIn, productId: item.productId),
          icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
        ),
        IconButton(
          tooltip: 'stock.stock_out'.tr,
          onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockOut, productId: item.productId),
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
        ),
      ],
    );
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: movement.isIn ? AppColors.success : AppColors.danger,
              ),
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
    if (!movement.isFromInvoice) return movement.note;
    if (movement.isIn) return 'stock.from_invoice_in'.trParams({'no': movement.invoiceNo});
    return 'stock.from_invoice_out'.trParams({'no': movement.invoiceNo});
  }
}

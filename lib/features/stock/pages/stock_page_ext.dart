part of 'stock_page.dart';

extension _StockPageExt on StockPage {
  Widget _toolbar(BuildContext context) {
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => StockMovementDialog.show(context),
          icon: const Icon(Icons.swap_vert_rounded),
          label: Text('stock.move'.tr),
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
        AppDataColumn(label: 'stock.profit'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'common.note'.tr, flex: 3),
      ],
      rows: [
        for (final movement in movements)
          [
            Text(_timeText(movement.createdAt)),
            Text(movement.productName),
            _typeBadge(movement),
            Text(
              _quantityText(movement),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: movement.isIn ? AppColors.success : AppColors.danger),
            ),
            _profitCell(context, movement),
            Text(_noteText(movement), style: Theme.of(context).textTheme.bodySmall),
          ],
      ],
      mobileRows: [for (final movement in movements) _mobileRow(context, movement)],
    );
  }

  String _quantityText(MovementModel movement) {
    return '${movement.isIn ? '+' : '-'}${movement.quantity} ${movement.unit}'.trim();
  }

  // มือถือ: ชื่อสินค้า + เวลา ซ้าย / จำนวน (+ เขียว, - แดง) + ป้ายประเภท ขวา / หมายเหตุ + กำไร ข้างล่าง (มีค่าเท่านั้น)
  Widget _mobileRow(BuildContext context, MovementModel movement) {
    final textTheme = Theme.of(context).textTheme;
    final note = _noteText(movement);
    final sign = movement.isIn ? '+' : '-';
    final quantity = '$sign${MoneyUtil.formatShort(movement.quantity.toDouble())} ${movement.unit}'.trim();
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.productName,
                      style: textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.spaceXSmall),
                    Text(_timeText(movement.createdAt), style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    quantity,
                    style: textTheme.titleMedium?.copyWith(
                      color: movement.isIn ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXSmall),
                  _typeBadge(movement),
                ],
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceSmall),
            Text(note, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
          if (movement.hasProfit) ...[const SizedBox(height: AppSizes.spaceSmall), _mobileProfit(context, movement)],
        ],
      ),
    );
  }

  // กำไรของแถวที่ขาย บนมือถือ: กล่องเทาอ่อน "กำไร +20.00  ขาย 59.00 · ทุน 39.00"
  Widget _mobileProfit(BuildContext context, MovementModel movement) {
    final textTheme = Theme.of(context).textTheme;
    final color = movement.profit < 0 ? AppColors.danger : AppColors.success;
    final sign = movement.profit > 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSmall + AppSizes.spaceXSmall,
        vertical: AppSizes.spaceSmall,
      ),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Wrap(
        spacing: AppSizes.spaceSmall,
        runSpacing: AppSizes.spaceXSmall,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('stock.profit'.tr, style: textTheme.bodySmall),
          Text('$sign${MoneyUtil.format(movement.profit)}', style: textTheme.titleSmall?.copyWith(color: color)),
          Text(
            'stock.profit_detail'.trParams({
              'sale': MoneyUtil.format(movement.saleAmount),
              'cost': MoneyUtil.format(movement.costAmount),
            }),
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(MovementModel movement) {
    if (movement.isMaterial) {
      return AppBadge(
        text: movement.isIn ? 'stock.material_returned'.tr : 'stock.material_used'.tr,
        color: AppColors.textPrimary,
        backgroundColor: AppColors.warningSoft,
      );
    }
    if (movement.isIn) {
      return AppBadge(text: 'stock.stock_in'.tr, color: AppColors.success, backgroundColor: AppColors.successSoft);
    }
    if (movement.isSale) {
      return AppBadge(text: 'stock.sold'.tr, color: AppColors.primaryDark, backgroundColor: AppColors.primarySoft);
    }
    return AppBadge(text: 'stock.stock_out'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft);
  }

  // แถวที่ขาย: กำไร (เขียว / ขาดทุนแดง) + ยอดขาย · ทุน ข้างล่าง / แถวอื่น: —
  Widget _profitCell(BuildContext context, MovementModel movement) {
    if (!movement.hasProfit) return const Text('—');
    final textTheme = Theme.of(context).textTheme;
    final color = movement.profit < 0 ? AppColors.danger : AppColors.success;
    final sign = movement.profit > 0 ? '+' : '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$sign${MoneyUtil.format(movement.profit)}', style: textTheme.titleSmall?.copyWith(color: color)),
        Text(
          'stock.profit_detail'.trParams({
            'sale': MoneyUtil.format(movement.saleAmount),
            'cost': MoneyUtil.format(movement.costAmount),
          }),
          textAlign: TextAlign.end,
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  String _timeText(DateTime time) {
    final minute = time.minute.toString().padLeft(2, '0');
    return '${DateUtil.toDisplayDate(time)} ${time.hour}:$minute';
  }

  String _noteText(MovementModel movement) {
    if (!movement.isFromInvoice || movement.isMaterial) {
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

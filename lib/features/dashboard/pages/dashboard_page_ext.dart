part of 'dashboard_page.dart';

extension _DashboardPageExt on DashboardPage {
  Widget _toolbar(BuildContext context, DashboardState state) {
    final bloc = context.read<DashboardBloc>();
    return PageToolbar(
      children: [
        MonthSwitcher(
          label: DateUtil.monthLabel(state.month),
          previousTooltip: 'common.previous_month'.tr,
          nextTooltip: 'common.next_month'.tr,
          onPrevious: () => bloc.add(DashboardMonthChanged(-1)),
          onNext: () => bloc.add(DashboardMonthChanged(1)),
        ),
      ],
    );
  }

  Widget? _stateView(BuildContext context, DashboardState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<DashboardBloc>().add(DashboardRequested()),
      );
    }
    return null;
  }

  Widget _stats(DashboardModel dashboard) {
    final isLoss = dashboard.profit < 0;
    return StatGrid(
      children: [
        StatCard(
          label: 'dashboard.income'.tr,
          value: MoneyUtil.format(dashboard.income),
          icon: Icons.south_west,
          color: AppColors.success,
          backgroundColor: AppColors.successSoft,
        ),
        StatCard(
          label: 'dashboard.expense'.tr,
          value: MoneyUtil.format(dashboard.expense),
          icon: Icons.north_east,
          color: AppColors.danger,
          backgroundColor: AppColors.dangerSoft,
        ),
        StatCard(
          label: 'dashboard.profit'.tr,
          value: MoneyUtil.format(dashboard.profit),
          icon: Icons.savings_outlined,
          color: isLoss ? AppColors.danger : AppColors.primary,
          backgroundColor: AppColors.primarySoft,
        ),
        StatCard(
          label: 'dashboard.invoices'.tr,
          value: MoneyUtil.format(dashboard.invoiceTotal),
          caption: 'dashboard.invoice_caption'.trParams({'count': '${dashboard.invoiceCount}'}),
          icon: Icons.receipt_long_outlined,
          color: AppColors.textPrimary,
          backgroundColor: AppColors.neutralSoft,
        ),
        StatCard(
          label: 'dashboard.products'.tr,
          value: '${dashboard.productCount}',
          icon: Icons.inventory_2_outlined,
          color: AppColors.textPrimary,
          backgroundColor: AppColors.neutralSoft,
        ),
        StatCard(
          label: 'dashboard.low_stock'.tr,
          value: '${dashboard.lowStockCount}',
          icon: Icons.warning_amber_rounded,
          color: dashboard.lowStockCount > 0 ? AppColors.danger : AppColors.success,
          backgroundColor: dashboard.lowStockCount > 0 ? AppColors.dangerSoft : AppColors.successSoft,
        ),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    return SectionCard(
      title: 'dashboard.quick_actions'.tr,
      child: Wrap(
        spacing: AppSizes.spaceSmall,
        runSpacing: AppSizes.spaceSmall,
        children: [
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.invoiceCreate),
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text('dashboard.new_invoice'.tr),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.transactions),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: Text('dashboard.new_transaction'.tr),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.stock),
            icon: const Icon(Icons.add_box_outlined),
            label: Text('dashboard.stock_in'.tr),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.products),
            icon: const Icon(Icons.inventory_2_outlined),
            label: Text('dashboard.new_product'.tr),
          ),
        ],
      ),
    );
  }

  Widget _lowStock(BuildContext context, DashboardModel dashboard) {
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      title: 'dashboard.low_stock_title'.tr,
      trailing: TextButton(onPressed: () => context.go(AppRoutes.stock), child: Text('common.view_all'.tr)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (dashboard.lowStock.isEmpty)
            Text('dashboard.low_stock_empty'.tr, style: textTheme.bodyMedium?.copyWith(color: AppColors.success)),
          for (final item in dashboard.lowStock)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
              child: Row(
                children: [
                  Expanded(child: Text(item.name, style: textTheme.titleSmall)),
                  const SizedBox(width: AppSizes.spaceSmall),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AppBadge(
                        text: 'dashboard.remaining'.trParams({
                          'stock': '${item.stock}',
                          'unit': item.unit,
                          'min': '${item.minStock}',
                        }),
                        color: AppColors.danger,
                        backgroundColor: AppColors.dangerSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

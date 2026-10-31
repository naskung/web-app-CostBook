part of 'dashboard_page.dart';

extension _DashboardPageExt on DashboardPage {
  Widget _header(BuildContext context, DashboardState state) {
    final bloc = context.read<DashboardBloc>();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Wrap(
        spacing: AppSizes.spaceSmall,
        runSpacing: AppSizes.spaceSmall,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          MonthSwitcher(
            label: DateUtil.monthLabel(state.month),
            previousTooltip: 'common.previous_month'.tr,
            nextTooltip: 'common.next_month'.tr,
            onPrevious: () => bloc.add(DashboardMonthChanged(-1)),
            onNext: () => bloc.add(DashboardMonthChanged(1)),
          ),
          Wrap(
            spacing: AppSizes.spaceSmall,
            runSpacing: AppSizes.spaceSmall,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.invoiceCreate),
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text('dashboard.new_invoice'.tr),
              ),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.sell),
                icon: const Icon(Icons.point_of_sale_outlined),
                label: Text('dashboard.sell'.tr),
              ),
            ],
          ),
        ],
      ),
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

  Widget _body(BuildContext context, DashboardState state) {
    final dashboard = state.dashboard;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppSizes.dashboardWideBreak;
        final rowHeight = isWide ? AppSizes.dashboardRowHeight : null;
        const gap = SizedBox(width: AppSizes.spaceMedium, height: AppSizes.spaceMedium);
        Widget row(Widget left, Widget right, {int leftFlex = 3, int rightFlex = 2}) {
          if (!isWide) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [left, gap, right]);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(flex: leftFlex, child: left), gap, Expanded(flex: rightFlex, child: right)],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kpis(dashboard, constraints.maxWidth),
            gap,
            row(_salesPanel(context, state, rowHeight, isWide), _weekdayPanel(context, dashboard, rowHeight)),
            gap,
            row(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_topProductsPanel(context, dashboard), gap, _expensePanel(dashboard)],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_marginPanel(context, dashboard), gap, const AiAskCard()],
              ),
            ),
            gap,
            _trendPanel(context, dashboard),
            gap,
            row(_marketPanel(context, dashboard), _stockPanel(context, dashboard)),
          ],
        );
      },
    );
  }

  Widget _kpis(DashboardModel dashboard, double width) {
    final previous = dashboard.previous;
    final columns = width >= AppSizes.kpiFourColumnBreak ? 4 : (width >= AppSizes.kpiTwoColumnBreak ? 2 : 1);
    final cardWidth = (width - AppSizes.spaceMedium * (columns - 1)) / columns;
    String last(String value) => 'dashboard.last_month_value'.trParams({'value': value});
    final cards = [
      KpiCard(
        label: 'dashboard.gross_profit'.tr,
        value: MoneyUtil.format(dashboard.sales.grossProfit),
        icon: Icons.trending_up,
        iconColor: AppColors.primary,
        change: PercentUtil.change(current: dashboard.sales.grossProfit, previous: previous.grossProfit),
        caption: last(MoneyUtil.format(previous.grossProfit)),
      ),
      KpiCard(
        label: 'dashboard.profit'.tr,
        value: MoneyUtil.format(dashboard.profit),
        valueColor: dashboard.profit < 0 ? AppColors.danger : AppColors.textPrimary,
        icon: Icons.savings_outlined,
        iconColor: AppColors.success,
        change: PercentUtil.change(current: dashboard.profit, previous: previous.profit),
        caption: last(MoneyUtil.format(previous.profit)),
      ),
      KpiCard(
        label: 'dashboard.bills'.tr,
        value: '${dashboard.invoiceCount}',
        icon: Icons.receipt_long_outlined,
        iconColor: AppColors.chartIncome,
        change: PercentUtil.change(current: dashboard.invoiceCount.toDouble(), previous: previous.bills.toDouble()),
        caption: last('${previous.bills}'),
      ),
      KpiCard(
        label: 'dashboard.expense'.tr,
        value: MoneyUtil.format(dashboard.expense),
        icon: Icons.north_east,
        iconColor: AppColors.chartExpense,
        change: PercentUtil.change(current: dashboard.expense, previous: previous.expense),
        upIsGood: false,
        caption: last(MoneyUtil.format(previous.expense)),
      ),
    ];
    return Wrap(
      spacing: AppSizes.spaceMedium,
      runSpacing: AppSizes.spaceMedium,
      children: [for (final card in cards) SizedBox(width: cardWidth, child: card)],
    );
  }
}

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

  // จอกว้าง: แถวละ 2 กล่อง สูงเท่ากันทุกกล่องในแถว (กำหนดความสูงต่อแถว) / จอแคบ: เรียงลงมาทีละกล่อง สูงตามเนื้อหา
  Widget _body(BuildContext context, DashboardState state) {
    final dashboard = state.dashboard;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppSizes.dashboardWideBreak;
        double? heightOf(double height) => isWide ? height : null;
        final chartHeight = heightOf(AppSizes.dashboardRowHeight);
        final listHeight = heightOf(AppSizes.dashboardListRowHeight);
        final compactHeight = heightOf(AppSizes.dashboardCompactRowHeight);
        const gap = SizedBox(width: AppSizes.spaceMedium, height: AppSizes.spaceMedium);
        Widget row(Widget left, Widget right) {
          if (!isWide) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [left, gap, right]);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(flex: 3, child: left), gap, Expanded(flex: 2, child: right)],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kpis(dashboard),
            row(_salesPanel(context, state, chartHeight), _weekdayPanel(context, dashboard, chartHeight)),
            gap,
            row(_topProductsPanel(context, dashboard, listHeight), _marginPanel(context, dashboard, listHeight)),
            gap,
            row(_expensePanel(context, dashboard, compactHeight), AiAskCard(height: compactHeight)),
            gap,
            _trendPanel(context, dashboard),
            gap,
            row(_marketPanel(context, dashboard, compactHeight), _stockPanel(context, dashboard, compactHeight)),
          ],
        );
      },
    );
  }

  // 4 การ์ดบน แบบเดียวกับหน้ารายรับ-รายจ่าย: รายได้ → กำไรขั้นต้น → รายจ่าย → กำไรสุทธิ (การ์ดผลลัพธ์พื้นเข้ม)
  Widget _kpis(DashboardModel dashboard) {
    final previous = dashboard.previous;
    final isLoss = dashboard.profit < 0;
    String last(double value) => 'dashboard.last_month_value'.trParams({'value': MoneyUtil.format(value)});
    Widget change(double current, double before, {bool upIsGood = true}) {
      return DeltaPill(change: PercentUtil.change(current: current, previous: before), upIsGood: upIsGood);
    }

    // การ์ดเล็กพอให้มือถือเป็น 2 × 2 ไม่ต้องเลื่อนยาว
    return StatGrid(
      maxColumns: 4,
      minCardWidth: AppSizes.statCardMiniWidth,
      children: [
        StatCard(
          label: 'dashboard.revenue'.tr,
          value: MoneyUtil.format(dashboard.revenue),
          icon: Icons.south_west,
          color: AppColors.success,
          backgroundColor: AppColors.successSoft,
          caption: last(previous.revenue),
          badge: change(dashboard.revenue, previous.revenue),
        ),
        StatCard(
          label: 'dashboard.gross_profit'.tr,
          value: MoneyUtil.format(dashboard.sales.grossProfit),
          icon: Icons.trending_up,
          color: AppColors.info,
          backgroundColor: AppColors.infoSoft,
          caption: last(previous.grossProfit),
          badge: change(dashboard.sales.grossProfit, previous.grossProfit),
        ),
        StatCard(
          label: 'dashboard.expense'.tr,
          value: MoneyUtil.format(dashboard.operatingExpense),
          icon: Icons.north_east,
          color: AppColors.danger,
          backgroundColor: AppColors.dangerSoft,
          caption: last(previous.operatingExpense),
          badge: change(dashboard.operatingExpense, previous.operatingExpense, upIsGood: false),
        ),
        StatCard(
          label: 'dashboard.profit'.tr,
          value: MoneyUtil.format(dashboard.profit),
          icon: Icons.savings_outlined,
          color: isLoss ? AppColors.danger : AppColors.primary,
          backgroundColor: isLoss ? AppColors.dangerSoft : AppColors.primarySoft,
          caption: last(previous.profit),
          valueColor: isLoss ? AppColors.dangerOnDark : null,
          isHighlighted: true,
          badge: change(dashboard.profit, previous.profit),
        ),
      ],
    );
  }
}

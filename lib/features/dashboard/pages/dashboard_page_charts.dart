part of 'dashboard_page.dart';

extension _DashboardPageCharts on DashboardPage {
  // ยังไม่มีข้อมูล: ไอคอน + ข้อความ อยู่กลางกล่อง
  Widget _emptyState(BuildContext context, IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.emptyStateIcon, color: AppColors.chartMuted),
        const SizedBox(height: AppSizes.spaceSmall),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ตัวเลขยอดขายใหญ่ + % เทียบเดือนก่อน แถวบน → กราฟยอดขายสะสมเต็มความกว้าง → ยอดตามหมวด
  Widget _salesPanel(BuildContext context, DashboardState state, double? height) {
    final dashboard = state.dashboard;
    final textTheme = Theme.of(context).textTheme;
    final sales = dashboard.sales;
    final now = DateTime.now();
    final isThisMonth = state.month.year == now.year && state.month.month == now.month;
    final change = PercentUtil.change(current: sales.netSales, previous: dashboard.previous.netSales);
    final details = [
      'dashboard.net_sales_caption'.trParams({
        'count': '${dashboard.invoiceCount}',
        'average': MoneyUtil.format(sales.averageBill),
      }),
      'dashboard.items_sold'.trParams({'count': '${sales.itemsSold}', 'vat': MoneyUtil.format(sales.vat)}),
    ].join(' · ');
    final chart = SalesTrendChart(
      days: dashboard.dailySales,
      previousDays: dashboard.previousDailySales,
      lastDay: isThisMonth ? now.day : dashboard.dailySales.length,
      monthLabel: DateUtil.shortMonthLabel(state.month),
      currentLabel: 'dashboard.this_month'.tr,
      previousLabel: 'dashboard.last_month'.tr,
      dayLabel: (day) => 'dashboard.day_label'.trParams({'day': '$day'}),
    );
    return DashboardPanel(
      title: 'dashboard.net_sales'.tr,
      subtitle: 'dashboard.sales_trend_caption'.tr,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSizes.spaceMedium,
            runSpacing: AppSizes.spaceXSmall,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                MoneyUtil.format(sales.netSales),
                style: textTheme.headlineMedium?.copyWith(fontSize: AppSizes.heroFont, fontWeight: FontWeight.w700),
              ),
              if (change != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DeltaPill(change: change),
                    const SizedBox(width: AppSizes.spaceSmall),
                    Text('dashboard.vs_last_month'.tr, style: textTheme.bodySmall),
                  ],
                ),
            ],
          ),
          Text(details, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.spaceMedium),
          if (height == null) SizedBox(height: AppSizes.salesChartHeight, child: chart) else Expanded(child: chart),
          if (dashboard.topCategories.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceMedium),
            CategorySplit(
              title: 'dashboard.category_sales'.tr,
              categories: dashboard.topCategories,
              emptyName: 'dashboard.no_category'.tr,
            ),
          ],
        ],
      ),
    );
  }

  Widget _weekdayPanel(BuildContext context, DashboardModel dashboard, double? height) {
    final totals = dashboard.weekdaySales;
    var best = 0;
    for (var i = 1; i < totals.length; i++) {
      if (totals[i] > totals[best]) best = i;
    }
    final chart = WeekdayChart(
      totals: totals,
      labels: [for (var i = 0; i < 7; i++) 'weekday_short.$i'.tr],
      tooltipText:
          (index) => 'dashboard.weekday_tooltip'.trParams({
            'day': 'weekday.$index'.tr,
            'sales': MoneyUtil.format(totals[index]),
          }),
    );
    return DashboardPanel(
      title: 'dashboard.weekday_title'.tr,
      subtitle:
          dashboard.hasSales
              ? 'dashboard.weekday_caption'.trParams({'day': 'weekday.$best'.tr})
              : 'dashboard.no_sales'.tr,
      height: height,
      child: height == null ? SizedBox(height: AppSizes.weekdayChartHeight, child: chart) : chart,
    );
  }

  Widget _topProductsPanel(BuildContext context, DashboardModel dashboard, double? height) {
    final hasProducts = dashboard.topProducts.isNotEmpty;
    return DashboardPanel(
      height: height,
      scrollable: hasProducts,
      centered: !hasProducts,
      title: 'dashboard.top_products'.tr,
      subtitle: 'dashboard.top_products_caption'.tr,
      trailing: TextButton(onPressed: () => context.go(AppRoutes.products), child: Text('common.view_all'.tr)),
      child:
          hasProducts
              ? TopProductsTable(
                products: dashboard.topProducts,
                labels: TopProductsColumns(
                  rank: 'dashboard.rank'.tr,
                  product: 'dashboard.product'.tr,
                  sold: 'dashboard.sold'.tr,
                  sales: 'dashboard.net_sales_short'.tr,
                  profit: 'dashboard.profit_short'.tr,
                  margin: 'dashboard.margin'.tr,
                ),
              )
              : _emptyState(context, Icons.emoji_events_outlined, 'dashboard.no_sales'.tr),
    );
  }

  Widget _marginPanel(BuildContext context, DashboardModel dashboard, double? height) {
    final margin = dashboard.sales.grossMargin;
    final useCostPage = context.watch<SettingsBloc>().state.company.useCostPage;
    return DashboardPanel(
      height: height,
      centered: true,
      title: 'dashboard.margin_title'.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MarginGauge(
            percent: margin < 0 ? 0 : margin,
            caption:
                dashboard.hasSales
                    ? 'dashboard.margin_caption'.trParams({'profit': MoneyUtil.format(margin)})
                    : 'dashboard.no_sales'.tr,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          OutlinedButton(
            onPressed: () => context.go(useCostPage ? AppRoutes.cost : AppRoutes.products),
            child: Text('dashboard.margin_details'.tr),
          ),
        ],
      ),
    );
  }

  Widget _trendPanel(BuildContext context, DashboardModel dashboard) {
    final months = dashboard.monthlyTrend;
    return DashboardPanel(
      title: 'dashboard.trend'.tr,
      subtitle: 'dashboard.trend_caption'.tr,
      child:
          dashboard.hasTrend
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MonthlyTrendChart(
                    months: months,
                    series: [
                      TrendSeries(
                        label: 'dashboard.series_income'.tr,
                        color: AppColors.chartIncome,
                        valueOf: (month) => month.revenue,
                      ),
                      TrendSeries(
                        label: 'dashboard.series_expense'.tr,
                        color: AppColors.chartExpense,
                        valueOf: (month) => month.totalCost,
                      ),
                      TrendSeries(
                        label: 'dashboard.series_profit'.tr,
                        color: AppColors.chartProfit,
                        valueOf: (month) => month.profit,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceMedium),
                  _trendNumbers(context, months),
                ],
              )
              : _emptyState(context, Icons.show_chart, 'dashboard.no_trend'.tr),
    );
  }

  // ตารางตัวเลขรายเดือน พับไว้ก่อน (กดดูได้) หน้าไม่ยาวเกิน
  Widget _trendNumbers(BuildContext context, List<MonthTotalsModel> months) {
    return ExpansionTile(
      title: Text('dashboard.show_numbers'.tr, style: Theme.of(context).textTheme.titleSmall),
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      children: [_trendTable(context, months)],
    );
  }

  Widget _trendTable(BuildContext context, List<MonthTotalsModel> months) {
    final textTheme = Theme.of(context).textTheme;
    Widget money(double value) => Text(MoneyUtil.format(value), style: textTheme.bodyMedium);
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'dashboard.month'.tr, flex: 2),
        AppDataColumn(label: 'dashboard.series_income'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'dashboard.series_expense'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'dashboard.series_profit'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'dashboard.net_sales_short'.tr, flex: 2, alignEnd: true),
      ],
      rows: [
        for (final month in months.reversed)
          [
            Text(month.monthDate == null ? month.month : DateUtil.monthLabel(month.monthDate ?? DateTime(1970))),
            money(month.revenue),
            money(month.totalCost),
            Text(
              MoneyUtil.format(month.profit),
              style: textTheme.titleSmall?.copyWith(color: month.profit < 0 ? AppColors.danger : AppColors.textPrimary),
            ),
            money(month.netSales),
          ],
      ],
    );
  }

  Widget _expensePanel(BuildContext context, DashboardModel dashboard, double? height) {
    final hasExpense = dashboard.expenseByCategory.isNotEmpty;
    return DashboardPanel(
      height: height,
      scrollable: hasExpense,
      centered: !hasExpense,
      title: 'dashboard.expense_by_category'.tr,
      subtitle: 'dashboard.expense_by_category_caption'.tr,
      child:
          hasExpense
              ? RankedBarList(
                color: AppColors.chartExpense,
                emptyText: 'dashboard.no_expense'.tr,
                items: [
                  for (final item in dashboard.expenseByCategory)
                    RankedBarItem(
                      label: 'transaction.category.${item.category}'.tr,
                      value: item.amount,
                      valueText: '${MoneyUtil.format(item.amount)} · ${PercentUtil.format(item.percent)}',
                    ),
                ],
              )
              : _emptyState(context, Icons.receipt_long_outlined, 'dashboard.no_expense'.tr),
    );
  }

  Widget _stockPanel(BuildContext context, DashboardModel dashboard, double? height) {
    final textTheme = Theme.of(context).textTheme;
    Widget figure(String label, String value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return DashboardPanel(
      height: height,
      scrollable: true,
      title: 'dashboard.stock_title'.tr,
      trailing: TextButton(onPressed: () => context.go(AppRoutes.lowStockProducts), child: Text('common.view_all'.tr)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              figure('dashboard.stock_value'.tr, MoneyUtil.format(dashboard.stock.costValue)),
              figure('dashboard.stock_retail'.tr, MoneyUtil.format(dashboard.stock.retailValue)),
              figure('dashboard.low_stock'.tr, '${dashboard.lowStockCount}'),
            ],
          ),
          const Divider(height: AppSizes.spaceLarge),
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

  Widget _marketPanel(BuildContext context, DashboardModel dashboard, double? height) {
    final hasMarket = dashboard.market.isNotEmpty;
    return DashboardPanel(
      height: height,
      scrollable: hasMarket,
      centered: !hasMarket,
      title: 'dashboard.market'.tr,
      subtitle: 'dashboard.market_caption'.tr,
      trailing: TextButton(onPressed: () => context.go(AppRoutes.products), child: Text('dashboard.market_check'.tr)),
      child:
          hasMarket
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final item in dashboard.market) _marketRow(context, item)],
              )
              : _emptyState(context, Icons.travel_explore, 'dashboard.market_empty'.tr),
    );
  }

  Widget _marketRow(BuildContext context, MarketPositionModel item) {
    final textTheme = Theme.of(context).textTheme;
    final range = MarketRangeBar(
      low: item.retailLow,
      high: item.retailHigh,
      typical: item.retailTypical,
      price: item.customerPrice,
      tooltip: 'market.range_tooltip'.trParams({
        'low': MoneyUtil.format(item.retailLow),
        'high': MoneyUtil.format(item.retailHigh),
        'typical': MoneyUtil.format(item.retailTypical),
        'price': MoneyUtil.format(item.customerPrice),
      }),
    );
    final name = InkWell(
      onTap: () => context.go(AppRoutes.marketPath(item.productId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: textTheme.titleSmall?.copyWith(decoration: TextDecoration.underline)),
          Text(
            'market.our_price'.trParams({'price': MoneyUtil.format(item.customerPrice)}),
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
    final badge = _positionBadge(item.position, item.diffPercent);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSmall),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < AppSizes.halfColumnBreak * 0.6) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [Expanded(child: name), badge]),
                const SizedBox(height: AppSizes.spaceXSmall),
                range,
              ],
            );
          }
          return Row(
            children: [
              SizedBox(width: AppSizes.rankedLabelWidth * 1.4, child: name),
              const SizedBox(width: AppSizes.spaceMedium),
              Expanded(child: range),
              const SizedBox(width: AppSizes.spaceMedium),
              SizedBox(
                width: AppSizes.rankedLabelWidth * 1.4,
                child: Align(alignment: Alignment.centerRight, child: badge),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _positionBadge(String position, double diffPercent) {
    final isWithin = position == 'within';
    final isUnknown = position == 'unknown';
    final diff = diffPercent == 0 ? '' : ' (${PercentUtil.format(diffPercent, showSign: true)})';
    return AppBadge(
      text: '${'market.position.$position'.tr}$diff',
      color: isWithin ? AppColors.success : (isUnknown ? AppColors.textSecondary : AppColors.warning),
      backgroundColor: isWithin ? AppColors.successSoft : (isUnknown ? AppColors.neutralSoft : AppColors.warningSoft),
    );
  }
}

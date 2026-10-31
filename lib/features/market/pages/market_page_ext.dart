part of 'market_page.dart';

extension _MarketPageExt on MarketPage {
  Widget? _stateView(BuildContext context, MarketState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<MarketBloc>().add(MarketOpened()),
      );
    }
    return null;
  }

  Widget _backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
        child: TextButton.icon(
          onPressed: () => context.go(AppRoutes.products),
          icon: const Icon(Icons.arrow_back),
          label: Text('market.back'.tr),
        ),
      ),
    );
  }

  double _customerPrice(ProductModel product, CompanyModel company) {
    return MarketUtil.customerPrice(
      sellPrice: product.sellPrice,
      vatRegistered: company.vatRegistered,
      pricesIncludeVat: company.pricesIncludeVat,
    );
  }

  double _netPrice(double customerPrice, CompanyModel company) {
    if (!company.vatRegistered) return customerPrice;
    return TaxUtil.priceBeforeVat(customerPrice);
  }

  Widget _header(BuildContext context, MarketState state, ProductModel product, CompanyModel company) {
    final textTheme = Theme.of(context).textTheme;
    final check = state.check;
    final checkedAt = check?.checkedAt;
    final details = [
      if (product.category.isNotEmpty) product.category,
      'market.our_cost'.trParams({'cost': MoneyUtil.format(product.costPrice)}),
      'market.our_price'.trParams({'price': MoneyUtil.format(_customerPrice(product, company))}),
    ];
    return SectionCard(
      title: product.name,
      subtitle: details.join(' · '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!state.canCheck) NoticeBanner(message: 'market.ai_off'.tr),
          Wrap(
            spacing: AppSizes.spaceSmall,
            runSpacing: AppSizes.spaceSmall,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed:
                    state.canCheck && !state.isChecking
                        ? () => context.read<MarketBloc>().add(MarketCheckRequested())
                        : null,
                icon: const Icon(Icons.travel_explore),
                label: Text(check == null ? 'market.check_now'.tr : 'market.check_again'.tr),
              ),
              if (checkedAt != null)
                Text(
                  'market.checked_at'.trParams({'date': DateUtil.toDisplayDate(checkedAt)}),
                  style: textTheme.bodySmall,
                ),
              if (check != null) _confidenceBadge(check.confidence),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmall),
          Text('market.check_note'.tr, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          if (check == null && !state.isChecking) ...[
            const SizedBox(height: AppSizes.spaceLarge),
            EmptyView(message: 'market.never_checked'.tr, icon: Icons.query_stats),
          ],
        ],
      ),
    );
  }

  Widget _confidenceBadge(String confidence) {
    final isHigh = confidence == 'high';
    final isLow = confidence == 'low';
    return AppBadge(
      text: 'market.confidence.$confidence'.tr,
      color: isHigh ? AppColors.success : (isLow ? AppColors.warning : AppColors.textSecondary),
      backgroundColor: isHigh ? AppColors.successSoft : (isLow ? AppColors.warningSoft : AppColors.neutralSoft),
    );
  }

  Widget _checking(BuildContext context) {
    return SectionCard(
      title: 'market.checking_title'.tr,
      child: Row(
        children: [
          const AppLoading(),
          const SizedBox(width: AppSizes.spaceMedium),
          Expanded(child: Text('market.checking'.tr)),
        ],
      ),
    );
  }

  String _range(double low, double high) {
    if (low <= 0 && high <= 0) return 'market.not_found'.tr;
    if (high <= 0 || low == high) return MoneyUtil.formatShort(low > 0 ? low : high);
    return '${MoneyUtil.formatShort(low)} – ${MoneyUtil.formatShort(high)}';
  }

  String _versus(double ours, double market) {
    final diff = MarketUtil.diffPercent(price: ours, typical: market);
    final text = 'market.ours'.trParams({'value': MoneyUtil.format(ours)});
    if (market <= 0) return text;
    return '$text (${PercentUtil.format(diff, showSign: true)})';
  }

  List<Widget> _result(BuildContext context, ProductModel product, MarketCheckModel check, CompanyModel company) {
    final customerPrice = _customerPrice(product, company);
    return [
      _stats(check, product, customerPrice),
      _position(context, check, customerPrice),
      _textCard(context, 'market.summary'.tr, check.summary),
      _profitCompare(context, product, check, customerPrice, company),
      _costItems(context, check),
      _textCard(context, 'market.advice'.tr, check.advice),
      _sources(context, check),
      Text(
        'market.disclaimer'.tr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
    ];
  }

  Widget _stats(MarketCheckModel check, ProductModel product, double customerPrice) {
    return StatGrid(
      maxColumns: 4,
      minCardWidth: AppSizes.statCardCompactWidth,
      children: [
        StatCard(
          label: 'market.retail'.tr,
          value: _range(check.retailLow, check.retailHigh),
          caption:
              check.retailTypical > 0
                  ? 'market.typical'.trParams({'price': MoneyUtil.format(check.retailTypical)})
                  : null,
          icon: Icons.storefront_outlined,
          color: AppColors.textPrimary,
          backgroundColor: AppColors.neutralSoft,
        ),
        StatCard(
          label: 'market.wholesale'.tr,
          value: _range(check.wholesaleLow, check.wholesaleHigh),
          caption: check.wholesaleNote.isEmpty ? null : check.wholesaleNote,
          icon: Icons.local_shipping_outlined,
          color: AppColors.textPrimary,
          backgroundColor: AppColors.neutralSoft,
        ),
        StatCard(
          label: 'market.market_cost'.tr,
          value: check.marketCost > 0 ? MoneyUtil.format(check.marketCost) : 'market.not_found'.tr,
          caption: _versus(product.costPrice, check.marketCost),
          icon: Icons.calculate_outlined,
          color: AppColors.textPrimary,
          backgroundColor: AppColors.neutralSoft,
        ),
        StatCard(
          label: 'market.suggested_price'.tr,
          value: check.suggestedPrice > 0 ? MoneyUtil.format(check.suggestedPrice) : 'market.not_found'.tr,
          caption: _versus(customerPrice, check.suggestedPrice),
          icon: Icons.sell_outlined,
          color: AppColors.primary,
          backgroundColor: AppColors.primarySoft,
        ),
      ],
    );
  }

  Widget _position(BuildContext context, MarketCheckModel check, double customerPrice) {
    final position = MarketUtil.position(price: customerPrice, low: check.retailLow, high: check.retailHigh);
    final diff = MarketUtil.diffPercent(price: customerPrice, typical: check.retailTypical);
    return SectionCard(
      title: 'market.compare_title'.tr,
      subtitle: 'market.position_text.$position'.trParams({'diff': PercentUtil.format(diff, showSign: true)}),
      child:
          check.hasRetail
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChartLegend(
                    items: [
                      ChartLegendItem(label: 'market.legend_ours'.tr, color: AppColors.primary),
                      ChartLegendItem(
                        label: 'market.legend_range'.tr,
                        color: AppColors.chartIncome.withValues(alpha: 0.35),
                      ),
                      ChartLegendItem(label: 'market.legend_typical'.tr, color: AppColors.chartIncome),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceMedium),
                  MarketRangeBar(
                    low: check.retailLow,
                    high: check.retailHigh,
                    typical: check.retailTypical,
                    price: customerPrice,
                    tooltip: 'market.range_tooltip'.trParams({
                      'low': MoneyUtil.format(check.retailLow),
                      'high': MoneyUtil.format(check.retailHigh),
                      'typical': MoneyUtil.format(check.retailTypical),
                      'price': MoneyUtil.format(customerPrice),
                    }),
                  ),
                ],
              )
              : Text('market.no_retail'.tr),
    );
  }

  Widget _textCard(BuildContext context, String title, String text) {
    if (text.isEmpty) return const SizedBox();
    return SectionCard(title: title, child: SelectableText(text, style: Theme.of(context).textTheme.bodyMedium));
  }

  Widget _profitCompare(
    BuildContext context,
    ProductModel product,
    MarketCheckModel check,
    double customerPrice,
    CompanyModel company,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final ourProfit = MoneyUtil.round2(_netPrice(customerPrice, company) - product.costPrice);
    final marketProfit = MoneyUtil.round2(_netPrice(check.retailTypical, company) - check.marketCost);
    final hasMarket = check.retailTypical > 0 && check.marketCost > 0;
    TableRow row(String label, String ours, String market, {bool isBold = false}) {
      final style = isBold ? textTheme.titleSmall : textTheme.bodyMedium;
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSmall),
            child: Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ),
          Text(ours, style: style, textAlign: TextAlign.end),
          Text(market, style: style, textAlign: TextAlign.end),
        ],
      );
    }

    String money(double value, bool isKnown) => isKnown ? MoneyUtil.format(value) : '-';
    return SectionCard(
      title: 'market.profit_title'.tr,
      subtitle: 'market.profit_caption'.tr,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
        children: [
          row('', 'market.col_ours'.tr, 'market.col_market'.tr, isBold: true),
          row('market.row_cost'.tr, MoneyUtil.format(product.costPrice), money(check.marketCost, check.marketCost > 0)),
          row(
            'market.row_price'.tr,
            MoneyUtil.format(customerPrice),
            money(check.retailTypical, check.retailTypical > 0),
          ),
          row('market.row_profit'.tr, MoneyUtil.format(ourProfit), money(marketProfit, hasMarket), isBold: true),
        ],
      ),
    );
  }

  Widget _costItems(BuildContext context, MarketCheckModel check) {
    final textTheme = Theme.of(context).textTheme;
    if (check.costItems.isEmpty) return const SizedBox();
    return SectionCard(
      title: 'market.cost_items'.tr,
      subtitle: 'market.cost_items_caption'.tr,
      child: Column(
        children: [
          for (final item in check.costItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: textTheme.titleSmall),
                        if (item.note.isNotEmpty) Text(item.note, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(MoneyUtil.format(item.amount), style: textTheme.bodyMedium),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              Expanded(child: Text('market.cost_total'.tr, style: textTheme.titleSmall)),
              Text(
                MoneyUtil.format(MoneyUtil.sum(check.costItems.map((item) => item.amount))),
                style: textTheme.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sources(BuildContext context, MarketCheckModel check) {
    final textTheme = Theme.of(context).textTheme;
    if (check.sources.isEmpty) return const SizedBox();
    return SectionCard(
      title: 'market.sources'.tr,
      subtitle: 'market.sources_caption'.tr,
      child: Column(
        children: [
          for (final source in check.sources)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(source.title, style: textTheme.titleSmall)),
                            const SizedBox(width: AppSizes.spaceSmall),
                            AppBadge(
                              text: 'market.kind.${source.kind}'.tr,
                              color: AppColors.textSecondary,
                              backgroundColor: AppColors.neutralSoft,
                            ),
                          ],
                        ),
                        SelectableText(
                          source.url,
                          maxLines: 1,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.chartIncome),
                        ),
                      ],
                    ),
                  ),
                  if (source.price > 0) Text(MoneyUtil.format(source.price), style: textTheme.bodyMedium),
                  IconButton(
                    tooltip: 'market.copy_link'.tr,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: source.url));
                      if (context.mounted) SnackbarHelper.showSuccess(context, 'market.link_copied'.tr);
                    },
                    icon: const Icon(Icons.copy, size: AppSizes.iconSmall),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

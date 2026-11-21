part of 'quotation_list_page.dart';

extension _QuotationListPageExt on QuotationListPage {
  Widget _toolbar(BuildContext context, QuotationListState state) {
    final bloc = context.read<QuotationListBloc>();
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.quotationCreate),
          icon: const Icon(Icons.add),
          label: Text('quotation.create'.tr),
        ),
      ],
      children: [DateRangePicker(range: state.range, onChanged: (range) => bloc.add(QuotationRangeChanged(range)))],
    );
  }

  Widget? _stateView(BuildContext context, QuotationListState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<QuotationListBloc>().add(QuotationsRequested()),
      );
    }
    if (state.quotations.isEmpty) return EmptyView(message: 'quotation.empty'.tr, icon: Icons.request_quote_outlined);
    return null;
  }

  Widget _table(BuildContext context, List<QuotationSummaryModel> quotations) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'invoice.no'.tr, flex: 2),
        AppDataColumn(label: 'common.date'.tr, flex: 2),
        AppDataColumn(label: 'invoice.customer'.tr, flex: 4),
        AppDataColumn(label: 'quotation.valid_until'.tr, flex: 2),
        AppDataColumn(label: 'invoice.total'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'invoice.status'.tr, flex: 2, alignEnd: true),
      ],
      onRowTap: (index) => context.go(AppRoutes.quotationDetailPath(quotations[index].id)),
      rows: [for (final quotation in quotations) _row(context, quotation)],
    );
  }

  List<Widget> _row(BuildContext context, QuotationSummaryModel quotation) {
    final textTheme = Theme.of(context).textTheme;
    return [
      Text(quotation.quotationNo, style: textTheme.titleSmall),
      Text(DateUtil.toDisplayDate(DateUtil.fromApiDate(quotation.issueDate))),
      Text(quotation.customerName, overflow: TextOverflow.ellipsis),
      Text(DateUtil.toDisplayDate(DateUtil.fromApiDate(quotation.validUntil))),
      MoneyText(quotation.total, style: textTheme.titleSmall),
      _statusBadge(quotation),
    ];
  }

  Widget _statusBadge(QuotationSummaryModel quotation) {
    if (quotation.isCancelled) {
      return AppBadge(
        text: 'invoice.status_cancelled'.tr,
        color: AppColors.danger,
        backgroundColor: AppColors.dangerSoft,
      );
    }
    return AppBadge(text: 'invoice.status_issued'.tr, color: AppColors.success, backgroundColor: AppColors.successSoft);
  }
}

part of 'invoice_list_page.dart';

extension _InvoiceListPageExt on InvoiceListPage {
  Widget _toolbar(BuildContext context, InvoiceListState state) {
    final bloc = context.read<InvoiceListBloc>();
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.invoiceCreate),
          icon: const Icon(Icons.add),
          label: Text(
            context.watch<SettingsBloc>().state.company.vatRegistered
                ? 'invoice.create'.tr
                : 'invoice.create_receipt'.tr,
          ),
        ),
      ],
      children: [
        MonthSwitcher(
          label: DateUtil.monthLabel(state.month),
          previousTooltip: 'common.previous_month'.tr,
          nextTooltip: 'common.next_month'.tr,
          onPrevious: () => bloc.add(InvoiceMonthChanged(-1)),
          onNext: () => bloc.add(InvoiceMonthChanged(1)),
        ),
      ],
    );
  }

  Widget? _stateView(BuildContext context, InvoiceListState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<InvoiceListBloc>().add(InvoicesRequested()),
      );
    }
    if (state.invoices.isEmpty) return EmptyView(message: 'invoice.empty'.tr, icon: Icons.receipt_long_outlined);
    return null;
  }

  // trackDelivery = ร้านเปิดติดตามการส่งสินค้า (หน้าตั้งค่า) → มีคอลัมน์การส่งสินค้า กดเปลี่ยนได้
  Widget _table(BuildContext context, List<InvoiceSummaryModel> invoices, {required bool trackDelivery}) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'invoice.no'.tr, flex: 2),
        AppDataColumn(label: 'common.date'.tr, flex: 2),
        AppDataColumn(label: 'invoice.customer'.tr, flex: 4),
        AppDataColumn(label: 'invoice.total'.tr, flex: 2, alignEnd: true),
        if (trackDelivery) AppDataColumn(label: 'invoice.delivery'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'invoice.status'.tr, flex: 2, alignEnd: true),
      ],
      onRowTap: (index) => context.go(AppRoutes.invoiceDetailPath(invoices[index].id)),
      rows: [for (final invoice in invoices) _row(context, invoice, trackDelivery: trackDelivery)],
    );
  }

  List<Widget> _row(BuildContext context, InvoiceSummaryModel invoice, {required bool trackDelivery}) {
    final textTheme = Theme.of(context).textTheme;
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(invoice.invoiceNo, style: textTheme.titleSmall),
          Text(
            invoice.isReceipt ? 'invoice.type_receipt'.tr : 'invoice.type_tax_invoice'.tr,
            style: textTheme.bodySmall,
          ),
        ],
      ),
      Text(DateUtil.toDisplayDate(DateUtil.fromApiDate(invoice.issueDate))),
      Text(
        invoice.customerName.isEmpty ? 'invoice.walk_in_customer'.tr : invoice.customerName,
        overflow: TextOverflow.ellipsis,
      ),
      MoneyText(invoice.total, style: textTheme.titleSmall),
      if (trackDelivery) _deliveryCell(context, invoice),
      _statusBadge(invoice),
    ];
  }

  // ใบที่ยกเลิกแล้ว ไม่มีของต้องส่ง → ช่องว่าง
  Widget _deliveryCell(BuildContext context, InvoiceSummaryModel invoice) {
    if (invoice.isCancelled) return const SizedBox.shrink();
    return DeliveryStatusMenu(
      status: invoice.deliveryStatus,
      onChanged:
          (status) => context.read<InvoiceListBloc>().add(
            InvoiceDeliveryChanged(invoiceId: invoice.id, deliveryStatus: status),
          ),
    );
  }

  Widget _statusBadge(InvoiceSummaryModel invoice) {
    if (invoice.isCancelled) {
      return AppBadge(
        text: 'invoice.status_cancelled'.tr,
        color: AppColors.danger,
        backgroundColor: AppColors.dangerSoft,
      );
    }
    return AppBadge(text: 'invoice.status_issued'.tr, color: AppColors.success, backgroundColor: AppColors.successSoft);
  }
}

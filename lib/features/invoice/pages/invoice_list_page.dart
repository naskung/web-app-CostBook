import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/invoice/bloc/invoice_list_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/money_text.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/load_more_footer.dart';
import 'package:costbook/shared/widgets/molecules/month_switcher.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

class InvoiceListPage extends StatelessWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceListBloc, InvoiceListState>(
      builder: (context, state) {
        final stateView = _stateView(context, state);
        final bloc = context.read<InvoiceListBloc>();
        return PageContent(
          centerChild: stateView,
          onLoadMore: state.canLoadMore ? () => bloc.add(InvoicesMoreRequested()) : null,
          children: [
            _toolbar(context, state),
            if (stateView == null) ...[
              _table(context, state.invoices),
              LoadMoreFooter(
                status: state.moreStatus,
                retryLabel: 'common.load_more_failed'.tr,
                onRetry: () => bloc.add(InvoicesMoreRequested()),
              ),
            ],
          ],
        );
      },
    );
  }

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

  Widget _table(BuildContext context, List<InvoiceSummaryModel> invoices) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'invoice.no'.tr, flex: 2),
        AppDataColumn(label: 'common.date'.tr, flex: 2),
        AppDataColumn(label: 'invoice.customer'.tr, flex: 4),
        AppDataColumn(label: 'invoice.total'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'invoice.status'.tr, flex: 2, alignEnd: true),
      ],
      onRowTap: (index) => context.go(AppRoutes.invoiceDetailPath(invoices[index].id)),
      rows: [for (final invoice in invoices) _row(context, invoice)],
    );
  }

  List<Widget> _row(BuildContext context, InvoiceSummaryModel invoice) {
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
      _statusBadge(invoice),
    ];
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

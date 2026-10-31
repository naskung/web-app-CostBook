part of 'transaction_list_page.dart';

extension _TransactionListPageExt on TransactionListPage {
  Widget _toolbar(BuildContext context, TransactionState state) {
    final bloc = context.read<TransactionBloc>();
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => _openNew(context, state, TransactionModel.income),
          style: FilledButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: AppColors.onDark),
          icon: const Icon(Icons.add),
          label: Text('transaction.add_income'.tr),
        ),
        FilledButton.icon(
          onPressed: () => _openNew(context, state, TransactionModel.expense),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.onDark),
          icon: const Icon(Icons.remove),
          label: Text('transaction.add_expense'.tr),
        ),
      ],
      children: [
        MonthSwitcher(
          label: DateUtil.monthLabel(state.month),
          previousTooltip: 'common.previous_month'.tr,
          nextTooltip: 'common.next_month'.tr,
          onPrevious: () => bloc.add(TransactionMonthChanged(-1)),
          onNext: () => bloc.add(TransactionMonthChanged(1)),
        ),
      ],
    );
  }

  void _openNew(BuildContext context, TransactionState state, String type) {
    final today = DateTime.now();
    final isThisMonth = today.year == state.month.year && today.month == state.month.month;
    final date = isThisMonth ? today : state.month;
    TransactionFormDialog.show(
      context,
      TransactionModel(type: type, category: '', amount: 0, date: DateUtil.toApiDate(date)),
    );
  }

  Widget? _stateView(BuildContext context, TransactionState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<TransactionBloc>().add(TransactionsRequested()),
      );
    }
    if (state.transactions.isEmpty) {
      return EmptyView(message: 'transaction.empty'.tr, icon: Icons.account_balance_wallet_outlined);
    }
    return null;
  }

  Widget _summary(TransactionState state) {
    final summary = state.summary;
    final isLoss = summary.profit < 0;
    return StatGrid(
      children: [
        StatCard(
          label: 'transaction.income'.tr,
          value: MoneyUtil.format(summary.income),
          icon: Icons.south_west,
          color: AppColors.success,
          backgroundColor: AppColors.successSoft,
        ),
        StatCard(
          label: 'transaction.expense'.tr,
          value: MoneyUtil.format(summary.expense),
          icon: Icons.north_east,
          color: AppColors.danger,
          backgroundColor: AppColors.dangerSoft,
        ),
        StatCard(
          label: 'transaction.profit'.tr,
          value: MoneyUtil.format(summary.profit),
          icon: Icons.savings_outlined,
          color: isLoss ? AppColors.danger : AppColors.primary,
          backgroundColor: AppColors.primarySoft,
        ),
      ],
    );
  }

  Widget _table(BuildContext context, List<TransactionModel> transactions) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'common.date'.tr, flex: 2),
        AppDataColumn(label: 'transaction.category'.tr, flex: 3),
        AppDataColumn(label: 'common.note'.tr, flex: 3),
        AppDataColumn(label: 'common.amount'.tr, flex: 2, alignEnd: true),
        const AppDataColumn(label: '', flex: 2, alignEnd: true),
      ],
      rows: [for (final transaction in transactions) _row(context, transaction)],
    );
  }

  List<Widget> _row(BuildContext context, TransactionModel transaction) {
    final textTheme = Theme.of(context).textTheme;
    final color = transaction.isIncome ? AppColors.success : AppColors.danger;
    return [
      Text(DateUtil.toDisplayDate(DateUtil.fromApiDate(transaction.date))),
      Text('transaction.category.${transaction.category}'.tr, style: textTheme.titleSmall),
      Text(_noteText(transaction), style: textTheme.bodySmall),
      MoneyText(
        transaction.amount,
        prefix: transaction.isIncome ? '+' : '-',
        color: color,
        style: textTheme.titleSmall,
      ),
      _actions(context, transaction),
    ];
  }

  String _noteText(TransactionModel transaction) {
    if (!transaction.isFromInvoice) return transaction.note;
    return 'transaction.from_invoice'.trParams({'no': transaction.invoiceNo});
  }

  Widget _actions(BuildContext context, TransactionModel transaction) {
    if (transaction.isFromInvoice) {
      return Tooltip(
        message: 'transaction.locked'.tr,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.lock_outline, color: AppColors.textSecondary),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'common.edit'.tr,
          onPressed: () => TransactionFormDialog.show(context, transaction),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'common.delete'.tr,
          onPressed: () => _confirmDelete(context, transaction),
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, TransactionModel transaction) async {
    final bloc = context.read<TransactionBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'transaction.delete_title'.tr,
      message: 'transaction.delete_message'.trParams({
        'category': 'transaction.category.${transaction.category}'.tr,
        'amount': MoneyUtil.format(transaction.amount),
      }),
      confirmText: 'common.delete'.tr,
    );
    if (isConfirmed) bloc.add(TransactionDeleted(transaction.id));
  }
}

part of 'cost_page.dart';

extension _CostPageExt on _CostPageState {
  Widget _noProducts(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyView(message: 'cost.no_products'.tr, icon: Icons.calculate_outlined),
        FilledButton(onPressed: () => context.go(AppRoutes.products), child: Text('cost.go_products'.tr)),
      ],
    );
  }

  Widget _productPicker(BuildContext context, CostState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: AppDropdown<String>(
            label: 'cost.choose_product'.tr,
            value: state.sheet?.productId,
            items: {for (final product in state.products) product.id: product.name},
            onChanged: (productId) => context.read<CostBloc>().add(CostProductSelected(productId ?? '')),
          ),
        ),
      ),
    );
  }

  Widget _sheetArea(BuildContext context, CostState state) {
    final sheet = state.sheet;
    if (state.sheetStatus == AppStatus.loading || sheet == null) return const AppLoading();
    if (ResponsiveHelper.screenType(context) == ScreenType.desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _itemsCard(context, sheet)),
          const SizedBox(width: AppSizes.spaceMedium),
          Expanded(flex: 2, child: _summaryCard(context, state, sheet)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_itemsCard(context, sheet), _summaryCard(context, state, sheet)],
    );
  }

  Widget _itemsCard(BuildContext context, CostSheetModel sheet) {
    return SectionCard(
      title: 'cost.items_title'.tr,
      subtitle: 'cost.items_subtitle'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final type in CostItemModel.types) _typeGroup(context, sheet, type)],
      ),
    );
  }

  Widget _typeGroup(BuildContext context, CostSheetModel sheet, String type) {
    final textTheme = Theme.of(context).textTheme;
    final items = sheet.itemsOf(type);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('cost.type.$type'.tr, style: textTheme.titleSmall)),
              MoneyText(sheet.totalOf(type), style: textTheme.titleSmall),
            ],
          ),
          const Divider(),
          if (items.isEmpty) Text('cost.empty_type'.tr, style: textTheme.bodySmall),
          for (final item in items) _itemRow(context, item),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addItem(type),
              icon: const Icon(Icons.add),
              label: Text('cost.add_item'.tr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, CostItemModel item) {
    return Row(
      children: [
        Expanded(child: Text(item.name)),
        MoneyText(item.amount),
        IconButton(
          tooltip: 'common.delete'.tr,
          onPressed: () => context.read<CostBloc>().add(CostItemRemoved(item)),
          icon: const Icon(Icons.close, size: AppSizes.iconSmall, color: AppColors.danger),
        ),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, CostState state, CostSheetModel sheet) {
    final bloc = context.read<CostBloc>();
    return SectionCard(
      title: 'cost.summary_title'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'cost.batch_quantity'.tr,
            controller: _batchController,
            keyboardType: TextInputType.number,
            suffixText: sheet.unit,
            onChanged: (text) => bloc.add(CostBatchQuantityChanged(int.tryParse(text.trim()) ?? 0)),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          _summaryLine(context, 'cost.total_cost'.tr, sheet.totalCost),
          _summaryLine(context, 'cost.cost_per_unit'.tr, sheet.costPerUnit, isBig: true),
          const Divider(height: AppSizes.spaceLarge),
          _markupRow(context),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: 'cost.sell_price'.tr,
            controller: _sellPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: 'common.baht'.tr,
            onChanged: (text) => bloc.add(CostSellPriceChanged(MoneyUtil.parse(text))),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          _summaryLine(context, 'cost.profit_per_unit'.tr, sheet.profitPerUnit),
          _summaryLine(context, 'cost.markup_result'.tr, sheet.markupPercent, suffix: ' %'),
          _summaryLine(context, 'cost.price_with_vat'.tr, TaxUtil.totalWithVat(sheet.sellPrice)),
          const SizedBox(height: AppSizes.spaceLarge),
          AppButton(
            text: 'common.save'.tr,
            isLoading: state.saveStatus == AppStatus.loading,
            onPressed: () => bloc.add(CostSheetSaved()),
          ),
        ],
      ),
    );
  }

  Widget _markupRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AppTextField(
            label: 'cost.markup'.tr,
            controller: _markupController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: '%',
          ),
        ),
        const SizedBox(width: AppSizes.spaceSmall),
        OutlinedButton(
          onPressed: () => context.read<CostBloc>().add(CostMarkupApplied(MoneyUtil.parse(_markupController.text))),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, AppSizes.buttonHeight)),
          child: Text('cost.apply_markup'.tr),
        ),
      ],
    );
  }

  Widget _summaryLine(BuildContext context, String label, double value, {bool isBig = false, String suffix = ''}) {
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = isBig ? textTheme.titleLarge?.copyWith(color: AppColors.primary) : textTheme.titleSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))),
          Text('${MoneyUtil.format(value)}$suffix', style: valueStyle),
        ],
      ),
    );
  }
}

part of 'cost_page.dart';

extension _CostPageExt on _CostPageState {
  // ยังไม่มีสินค้า ก็ตั้งรายการต้นทุนที่ใช้บ่อยไว้ก่อนได้
  Widget _noProducts(BuildContext context, CostState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyView(message: 'cost.no_products'.tr, icon: Icons.calculate_outlined),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSizes.spaceSmall,
          runSpacing: AppSizes.spaceSmall,
          children: [
            FilledButton(onPressed: () => context.go(AppRoutes.products), child: Text('cost.go_products'.tr)),
            _presetsButton(context, state),
          ],
        ),
      ],
    );
  }

  Widget _presetsButton(BuildContext context, CostState state) {
    return OutlinedButton.icon(
      onPressed: () => CostPresetsDialog.show(context),
      icon: const Icon(Icons.bookmark_border),
      label: Text('cost.presets_button'.trParams({'count': '${state.presets.length}'})),
    );
  }

  Widget _productPicker(BuildContext context, CostState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Wrap(
        spacing: AppSizes.spaceMedium,
        runSpacing: AppSizes.spaceMedium,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
            child: AppDropdown<String>(
              label: 'cost.choose_product'.tr,
              value: state.sheet?.productId,
              items: {for (final product in state.products) product.id: product.name},
              onChanged: (productId) => context.read<CostBloc>().add(CostProductSelected(productId ?? '')),
            ),
          ),
          _presetsButton(context, state),
        ],
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
          for (final item in items) _itemRow(context, sheet, item),
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

  Widget _itemRow(BuildContext context, CostSheetModel sheet, CostItemModel item) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => _editItem(item),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(item.name)),
                    if (item.isMaterial) ...[
                      const SizedBox(width: AppSizes.spaceSmall),
                      AppBadge(
                        text: 'cost.from_stock'.tr,
                        color: AppColors.textPrimary,
                        backgroundColor: AppColors.warningSoft,
                      ),
                    ],
                  ],
                ),
                Text(_itemDetail(item), style: textTheme.bodySmall),
              ],
            ),
          ),
          MoneyText(sheet.amountOf(item)),
          IconButton(
            tooltip: 'common.delete'.tr,
            onPressed: () => context.read<CostBloc>().add(CostItemRemoved(item)),
            icon: const Icon(Icons.close, size: AppSizes.iconSmall, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  String _itemDetail(CostItemModel item) {
    if (item.isPercent) return 'cost.percent_detail'.trParams({'percent': MoneyUtil.format(item.percent)});
    final quantity = MoneyUtil.format(item.quantity).replaceAll(RegExp(r'\.00$'), '');
    return '$quantity ${item.unit} × ${MoneyUtil.format(item.unitPrice)}'.replaceAll('  ', ' ');
  }

  Widget _summaryCard(BuildContext context, CostState state, CostSheetModel sheet) {
    final bloc = context.read<CostBloc>();
    final company = context.watch<SettingsBloc>().state.company;
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
          _markupRow(context, company.priceHasVat),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: _sellPriceLabel(company),
            controller: _sellPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: 'common.baht'.tr,
            onChanged: (text) => bloc.add(CostSellPriceChanged(MoneyUtil.parse(text))),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          if (company.priceHasVat)
            _summaryLine(context, 'cost.price_before_vat'.tr, sheet.netSellPrice(priceHasVat: true)),
          _summaryLine(context, 'cost.profit_per_unit'.tr, sheet.profitPerUnit(priceHasVat: company.priceHasVat)),
          _summaryLine(
            context,
            'cost.markup_result'.tr,
            sheet.markupPercent(priceHasVat: company.priceHasVat),
            suffix: ' %',
          ),
          if (company.vatRegistered && !company.pricesIncludeVat)
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

  String _sellPriceLabel(CompanyModel company) {
    if (!company.vatRegistered) return 'cost.sell_price_no_vat'.tr;
    if (company.pricesIncludeVat) return 'cost.sell_price_include_vat'.tr;
    return 'cost.sell_price'.tr;
  }

  Widget _markupRow(BuildContext context, bool priceHasVat) {
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
          onPressed:
              () => context.read<CostBloc>().add(
                CostMarkupApplied(MoneyUtil.parse(_markupController.text), priceHasVat: priceHasVat),
              ),
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

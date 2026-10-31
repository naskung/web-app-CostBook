part of 'sell_page.dart';

extension _SellPageExt on _SellPageState {
  Widget _layout(BuildContext context, InvoiceFormState state) {
    if (ResponsiveHelper.screenType(context) == ScreenType.desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _productArea(context, state)),
          const SizedBox(width: AppSizes.spaceMedium),
          SizedBox(width: AppSizes.sellCartWidth, child: _cartArea(context, state)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_productArea(context, state), const SizedBox(height: AppSizes.spaceMedium), _cartArea(context, state)],
    );
  }

  Widget _productArea(BuildContext context, InvoiceFormState state) {
    final products = state.productsMatching(_query);
    return SectionCard(
      title: 'sell.products_title'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            autofocus: true,
            onChanged: _onQueryChanged,
            onSubmitted: _onCodeSubmitted,
            decoration: InputDecoration(hintText: 'sell.search_hint'.tr, prefixIcon: const Icon(Icons.qr_code_scanner)),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          if (products.isEmpty) EmptyView(message: 'product.not_found'.tr, icon: Icons.search_off),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = _tileWidth(constraints.maxWidth);
              return Wrap(
                spacing: AppSizes.spaceSmall,
                runSpacing: AppSizes.spaceSmall,
                children: [for (final product in products) _productTile(context, product, tileWidth)],
              );
            },
          ),
        ],
      ),
    );
  }

  double _tileWidth(double areaWidth) {
    final columns = (areaWidth / AppSizes.sellTileWidth).floor().clamp(2, 6);
    return (areaWidth - AppSizes.spaceSmall * (columns - 1)) / columns;
  }

  Widget _productTile(BuildContext context, ProductModel product, double width) {
    final stockText =
        product.trackStock ? 'invoice.in_stock'.trParams({'stock': '${product.stock}'}) : 'product.no_stock'.tr;
    return SellProductTile(
      width: width,
      name: product.name,
      price: product.sellPrice,
      stockText: stockText,
      isOut: product.trackStock && product.stock <= 0,
      onTap: () => context.read<InvoiceFormBloc>().add(InvoiceItemAdded(product.id)),
    );
  }

  Widget _cartArea(BuildContext context, InvoiceFormState state) {
    final bloc = context.read<InvoiceFormBloc>();
    return SectionCard(
      title: 'sell.cart_title'.trParams({'count': '${state.itemCount}'}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.company.needsTaxId) NoticeBanner(message: 'invoice.tax_id_missing'.tr),
          if (state.items.isEmpty) Text('sell.cart_empty'.tr, style: Theme.of(context).textTheme.bodySmall),
          for (final item in state.items)
            InvoiceItemRow(
              key: ValueKey(item.productId),
              item: item,
              onChanged:
                  (quantity, unitPrice) =>
                      bloc.add(InvoiceItemChanged(productId: item.productId, quantity: quantity, unitPrice: unitPrice)),
              onRemove: () => bloc.add(InvoiceItemRemoved(item.productId)),
            ),
          const SizedBox(height: AppSizes.spaceSmall),
          AppTextField(
            label: state.needsCustomerName ? 'invoice.customer_name'.tr : 'sell.customer_optional'.tr,
            controller: _customerController,
            validator: state.needsCustomerName ? _requiredCustomer : null,
          ),
          _totals(context, state),
          const SizedBox(height: AppSizes.spaceMedium),
          AppButton(
            text: 'sell.pay'.trParams({'total': MoneyUtil.format(state.amounts.total)}),
            isLoading: state.submitStatus == AppStatus.loading,
            onPressed: state.items.isEmpty ? null : _onSubmit,
          ),
        ],
      ),
    );
  }

  String? _requiredCustomer(String? value) {
    if (value == null || value.trim().isEmpty) return 'validation.required'.tr;
    return null;
  }

  Widget _totals(BuildContext context, InvoiceFormState state) {
    final amounts = state.amounts;
    final isVat = state.company.vatRegistered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.spaceMedium),
        _line(context, 'invoice.items_total'.tr, amounts.itemsTotal),
        Row(
          children: [
            Expanded(child: Text('invoice.discount'.tr)),
            SizedBox(
              width: AppSizes.monthLabelWidth,
              child: TextField(
                controller: _discountController,
                textAlign: TextAlign.end,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: '0.00', isDense: true),
                onChanged: (text) => context.read<InvoiceFormBloc>().add(InvoiceDiscountChanged(MoneyUtil.parse(text))),
              ),
            ),
          ],
        ),
        if (isVat) _line(context, 'invoice.vat'.tr, amounts.vat),
        const Divider(),
        _line(context, 'invoice.grand_total'.tr, amounts.total, isBig: true),
      ],
    );
  }

  Widget _line(BuildContext context, String label, double value, {bool isBig = false}) {
    final textTheme = Theme.of(context).textTheme;
    final style = isBig ? textTheme.titleLarge?.copyWith(color: AppColors.primary) : textTheme.titleSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Row(
        children: [
          Expanded(child: Text(label, style: isBig ? textTheme.titleMedium : textTheme.bodyMedium)),
          Text(MoneyUtil.format(value), style: style),
        ],
      ),
    );
  }

  Future<bool> _showSoldDialog(BuildContext context, InvoiceModel invoice) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: AppColors.success, size: AppSizes.iconBox),
            title: Text('sell.sold_title'.tr),
            content: Text(
              'sell.sold_message'.trParams({'no': invoice.invoiceNo, 'total': MoneyUtil.format(invoice.total)}),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text('sell.view_bill'.tr)),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('sell.next_sale'.tr)),
            ],
          ),
    );
    return result ?? false;
  }
}

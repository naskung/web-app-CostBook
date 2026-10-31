part of 'product_list_page.dart';

extension _ProductListPageExt on ProductListPage {
  Widget _toolbar(BuildContext context) {
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => ProductFormDialog.show(context, const ProductModel(name: '')),
          icon: const Icon(Icons.add),
          label: Text('product.add'.tr),
        ),
      ],
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: SearchField(
            hint: 'product.search_hint'.tr,
            onChanged: (query) => context.read<ProductBloc>().add(ProductSearchChanged(query)),
          ),
        ),
      ],
    );
  }

  Widget? _stateView(BuildContext context, ProductState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<ProductBloc>().add(ProductsRequested()),
      );
    }
    if (state.products.isEmpty) return EmptyView(message: 'product.empty'.tr, icon: Icons.inventory_2_outlined);
    if (state.visibleProducts.isEmpty) return EmptyView(message: 'product.not_found'.tr, icon: Icons.search_off);
    return null;
  }

  Widget _table(BuildContext context, List<ProductModel> products) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'product.name'.tr, flex: 3),
        AppDataColumn(label: 'product.cost_price'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'product.sell_price'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'product.stock'.tr, flex: 2, alignEnd: true),
        const AppDataColumn(label: '', flex: 2, alignEnd: true),
      ],
      onRowTap: (index) => ProductFormDialog.show(context, products[index]),
      rows: [for (final product in products) _row(context, product)],
    );
  }

  List<Widget> _row(BuildContext context, ProductModel product) {
    final textTheme = Theme.of(context).textTheme;
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: textTheme.titleSmall),
          if (product.unit.isNotEmpty) Text(product.unit, style: textTheme.bodySmall),
        ],
      ),
      MoneyText(product.costPrice),
      MoneyText(product.sellPrice, style: textTheme.titleSmall),
      _stockCell(context, product),
      _actions(context, product),
    ];
  }

  Widget _stockCell(BuildContext context, ProductModel product) {
    return Wrap(
      spacing: AppSizes.spaceSmall,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (product.isLowStock)
          AppBadge(text: 'product.low'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft),
        Text('${product.stock} ${product.unit}'),
      ],
    );
  }

  Widget _actions(BuildContext context, ProductModel product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'common.edit'.tr,
          onPressed: () => ProductFormDialog.show(context, product),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'common.delete'.tr,
          onPressed: () => _confirmDelete(context, product),
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProductModel product) async {
    final bloc = context.read<ProductBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'product.delete_title'.tr,
      message: 'product.delete_message'.trParams({'name': product.name}),
      confirmText: 'common.delete'.tr,
    );
    if (isConfirmed) bloc.add(ProductDeleted(product.id));
  }
}

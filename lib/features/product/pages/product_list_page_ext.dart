part of 'product_list_page.dart';

extension _ProductListPageExt on ProductListPage {
  Widget _toolbar(BuildContext context, ProductState state, List<ProductFieldModel> fields) {
    final bloc = context.read<ProductBloc>();
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => ProductFormDialog.show(context, const ProductModel(name: ''), fields, state.categories),
          icon: const Icon(Icons.add),
          label: Text('product.add'.tr),
        ),
        OutlinedButton.icon(
          onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockIn),
          icon: const Icon(Icons.add_circle_outline),
          label: Text('stock.stock_in'.tr),
        ),
        OutlinedButton.icon(
          onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockOut),
          icon: const Icon(Icons.remove_circle_outline),
          label: Text('stock.stock_out'.tr),
        ),
      ],
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: SearchField(
            hint: 'product.search_hint'.tr,
            onChanged: (query) => bloc.add(ProductSearchChanged(query)),
          ),
        ),
      ],
    );
  }

  // ตัวกรอง: หมวด (จากเมนู หมวดหมู่สินค้า) + เฉพาะใกล้หมด
  Widget _filters(BuildContext context, ProductState state) {
    final bloc = context.read<ProductBloc>();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Wrap(
        spacing: AppSizes.spaceSmall,
        runSpacing: AppSizes.spaceSmall,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ChoiceChip(
            label: Text('product.all_categories'.tr),
            selected: state.category.isEmpty,
            onSelected: (_) => bloc.add(ProductCategoryChanged('')),
          ),
          for (final category in state.categories)
            ChoiceChip(
              label: Text(category.name),
              selected: state.category == category.id,
              onSelected: (_) => bloc.add(ProductCategoryChanged(category.id)),
            ),
          FilterChip(
            label: Text('product.only_low'.trParams({'count': '${state.lowStockCount}'})),
            selected: state.onlyLow,
            onSelected: (selected) => bloc.add(ProductLowStockFilterChanged(onlyLow: selected)),
          ),
        ],
      ),
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
    if (state.visibleProducts.isEmpty && state.onlyLow) {
      return EmptyView(message: 'stock.low_empty'.tr, icon: Icons.check_circle_outline);
    }
    if (state.visibleProducts.isEmpty) return EmptyView(message: 'product.not_found'.tr, icon: Icons.search_off);
    return null;
  }

  Widget _table(BuildContext context, ProductState state, SettingsState settings) {
    final products = state.visibleProducts;
    final listFields = settings.listFields;
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'product.name'.tr, flex: 3),
        for (final field in listFields) AppDataColumn(label: field.name, flex: 2),
        AppDataColumn(label: 'product.cost_price'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'product.sell_price'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'product.stock'.tr, flex: 2, alignEnd: true),
        const AppDataColumn(label: '', flex: 4, alignEnd: true),
      ],
      onRowTap: (index) => ProductFormDialog.show(context, products[index], settings.fields, state.categories),
      rows: [for (final product in products) _row(context, product, listFields, settings.fields, state.categories)],
    );
  }

  List<Widget> _row(
    BuildContext context,
    ProductModel product,
    List<ProductFieldModel> listFields,
    List<ProductFieldModel> fields,
    List<ProductCategoryModel> categories,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return [
      _nameCell(context, product),
      for (final field in listFields) Text(_fieldText(field, product.fieldValue(field.id))),
      MoneyText(product.costPrice),
      MoneyText(product.sellPrice, style: textTheme.titleSmall),
      _stockCell(context, product),
      _actions(context, product, fields, categories),
    ];
  }

  String _fieldText(ProductFieldModel field, String value) {
    if (field.type != ProductFieldModel.date || value.isEmpty) return value;
    return DateUtil.toDisplayDate(DateUtil.fromApiDate(value));
  }

  Widget _nameCell(BuildContext context, ProductModel product) {
    final textTheme = Theme.of(context).textTheme;
    final details = [product.code, product.category, product.unit].where((text) => text.isNotEmpty).join(' · ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProductImage(product: product, width: AppSizes.productThumb, height: AppSizes.productThumb),
        const SizedBox(width: AppSizes.spaceSmall + AppSizes.spaceXSmall),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: textTheme.titleSmall),
              if (details.isNotEmpty) Text(details, style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stockCell(BuildContext context, ProductModel product) {
    if (!product.trackStock) {
      return AppBadge(
        text: 'product.no_stock'.tr,
        color: AppColors.textSecondary,
        backgroundColor: AppColors.neutralSoft,
      );
    }
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

  Widget _actions(
    BuildContext context,
    ProductModel product,
    List<ProductFieldModel> fields,
    List<ProductCategoryModel> categories,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (product.trackStock) ...[
          IconButton(
            tooltip: 'stock.stock_in'.tr,
            onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockIn, productId: product.id),
            icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
          ),
          IconButton(
            tooltip: 'stock.stock_out'.tr,
            onPressed: () => StockMovementDialog.show(context, type: MovementModel.stockOut, productId: product.id),
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
          ),
        ],
        IconButton(
          tooltip: 'market.check_tooltip'.tr,
          onPressed: () => context.go(AppRoutes.marketPath(product.id)),
          icon: const Icon(Icons.travel_explore),
        ),
        IconButton(
          tooltip: 'common.edit'.tr,
          onPressed: () => ProductFormDialog.show(context, product, fields, categories),
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

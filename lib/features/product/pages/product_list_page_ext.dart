part of 'product_list_page.dart';

// เมนู ⋮ ท้ายแถวสินค้า
enum _RowAction { market, edit, delete }

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
          onPressed: () => StockMovementDialog.show(context),
          icon: const Icon(Icons.swap_vert_rounded),
          label: Text('stock.move'.tr),
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
            avatar: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
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
    if (state.counts.all == 0) return EmptyView(message: 'product.empty'.tr, icon: Icons.inventory_2_outlined);
    if (state.products.isEmpty && state.onlyLow) {
      return EmptyView(message: 'stock.low_empty'.tr, icon: Icons.check_circle_outline);
    }
    if (state.kind == ProductState.kindMaterial && state.kindCount(ProductState.kindMaterial) == 0) {
      return EmptyView(message: 'product.material_empty'.tr, icon: Icons.layers_outlined);
    }
    if (state.products.isEmpty) return EmptyView(message: 'product.not_found'.tr, icon: Icons.search_off);
    return null;
  }

  // แถบโหลดบาง ๆ เหนือตาราง ตอนโหลดใหม่ตามตัวกรองที่เพิ่งเปลี่ยน (จองที่ไว้เสมอ ตารางไม่กระตุก)
  Widget _filteringBar(ProductState state) {
    return SizedBox(
      height: AppSizes.filteringBarHeight,
      child: state.isFiltering ? const LinearProgressIndicator() : null,
    );
  }

  Widget _table(BuildContext context, ProductState state, SettingsState settings) {
    final products = state.products;
    final listFields = settings.listFields;
    return AppDataTable(
      header: _kindTabs(context, state),
      columns: [
        AppDataColumn(label: 'product.name'.tr, flex: 5, minWidth: AppSizes.productNameMinWidth),
        for (final field in listFields) AppDataColumn(label: field.name, flex: 2),
        AppDataColumn(label: 'product.cost_price'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'product.sell_price'.tr, flex: 2, alignEnd: true),
        AppDataColumn(label: 'product.stock'.tr, flex: 2, alignEnd: true, minWidth: AppSizes.productStockMinWidth),
        const AppDataColumn(label: '', alignEnd: true, width: AppSizes.tableActionsWidth),
      ],
      onRowTap: (index) => ProductFormDialog.show(context, products[index], settings.fields, state.categories),
      rows: [for (final product in products) _row(context, product, listFields, settings.fields, state.categories)],
    );
  }

  // แท็บ ทั้งหมด / สินค้าขาย / วัสดุ ติดอยู่บนตารางสินค้า
  Widget _kindTabs(BuildContext context, ProductState state) {
    return AppTabs(
      selected: state.kind,
      onChanged: (kind) => context.read<ProductBloc>().add(ProductKindChanged(kind)),
      tabs: [
        AppTab(value: '', label: 'product.kind_all'.tr, icon: Icons.grid_view_rounded, count: state.kindCount('')),
        AppTab(
          value: ProductState.kindForSale,
          label: 'product.kind_for_sale'.tr,
          icon: Icons.sell_outlined,
          count: state.kindCount(ProductState.kindForSale),
        ),
        AppTab(
          value: ProductState.kindMaterial,
          label: 'product.kind_material'.tr,
          icon: Icons.layers_outlined,
          count: state.kindCount(ProductState.kindMaterial),
        ),
      ],
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
      product.forSale ? MoneyText(product.sellPrice, style: textTheme.titleSmall) : const Text('—'),
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
              if (!product.forSale || details.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceXSmall),
                _nameDetails(context, product, details),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // บรรทัดที่ 2 ใต้ชื่อ: ป้ายวัสดุ + รหัส · หมวด · หน่วย — ป้ายอยู่ตรงนี้เสมอ ชื่อสั้น / ยาวหน้าตาเหมือนกัน
  Widget _nameDetails(BuildContext context, ProductModel product, String details) {
    return Wrap(
      spacing: AppSizes.spaceSmall,
      runSpacing: AppSizes.spaceXSmall,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!product.forSale)
          AppBadge(
            text: 'product.kind_material'.tr,
            color: AppColors.textPrimary,
            backgroundColor: AppColors.warningSoft,
          ),
        if (details.isNotEmpty) Text(details, style: Theme.of(context).textTheme.bodySmall),
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
    // จำนวนอยู่บรรทัดบน ป้ายใกล้หมดอยู่ข้างล่าง → ทุกแถวหน้าตาเหมือนกัน ไม่ตกบรรทัดบ้างไม่ตกบ้าง
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${product.stock} ${product.unit}', maxLines: 1, softWrap: false),
        if (product.isLowStock) ...[
          const SizedBox(height: AppSizes.spaceXSmall),
          AppBadge(text: 'product.low'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft),
        ],
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
        if (product.trackStock)
          IconButton(
            tooltip: 'stock.move'.tr,
            onPressed: () => StockMovementDialog.show(context, productId: product.id),
            icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primaryDark),
          ),
        PopupMenuButton<_RowAction>(
          tooltip: 'common.more'.tr,
          icon: const Icon(Icons.more_vert),
          onSelected: (action) => _onRowAction(context, action, product, fields, categories),
          itemBuilder:
              (context) => [
                _menuItem(context, _RowAction.market, Icons.travel_explore, 'market.check_tooltip'.tr),
                _menuItem(context, _RowAction.edit, Icons.edit_outlined, 'common.edit'.tr),
                _menuItem(
                  context,
                  _RowAction.delete,
                  Icons.delete_outline,
                  'common.delete'.tr,
                  color: AppColors.danger,
                ),
              ],
        ),
      ],
    );
  }

  PopupMenuItem<_RowAction> _menuItem(
    BuildContext context,
    _RowAction action,
    IconData icon,
    String label, {
    Color color = AppColors.textPrimary,
  }) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSizes.iconSmall),
          const SizedBox(width: AppSizes.spaceMedium),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _onRowAction(
    BuildContext context,
    _RowAction action,
    ProductModel product,
    List<ProductFieldModel> fields,
    List<ProductCategoryModel> categories,
  ) {
    if (action == _RowAction.market) {
      context.go(AppRoutes.marketPath(product.id));
      return;
    }
    if (action == _RowAction.edit) {
      ProductFormDialog.show(context, product, fields, categories);
      return;
    }
    _confirmDelete(context, product);
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

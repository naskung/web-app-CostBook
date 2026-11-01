part of 'sell_page.dart';

extension _SellPageExt on _SellPageState {
  // จอคอม / แท็บเล็ต: สินค้า | บิล — ใต้บิลเว้นที่ให้ปุ่มแชท AI (มุมขวาล่าง) ไม่บังปุ่มรับเงิน
  Widget _wideLayout(BuildContext context, InvoiceFormState state) {
    final isDesktop = ResponsiveHelper.screenType(context) == ScreenType.desktop;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceLarge, AppSizes.spaceLarge, AppSizes.spaceLarge, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceLarge),
              child: _productPane(context, state),
            ),
          ),
          const SizedBox(width: AppSizes.spaceMedium),
          SizedBox(
            width: isDesktop ? AppSizes.sellBillWidth : AppSizes.sellBillCompactWidth,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.chatLauncherSpace),
              child: _billPanel(onPay: _onPay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileLayout(BuildContext context, InvoiceFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceMedium,
              AppSizes.spaceMedium,
              AppSizes.spaceMedium,
              AppSizes.spaceSmall,
            ),
            child: _productPane(context, state),
          ),
        ),
        _cartBar(context, state),
      ],
    );
  }

  Widget _billPanel({required VoidCallback onPay, VoidCallback? onClose}) {
    return SellBillPanel(
      customerController: _customerController,
      discountController: _discountController,
      onPay: onPay,
      onClear: _confirmClear,
      onClose: onClose,
    );
  }

  // มือถือ: แถบติดล่าง จำนวนชิ้น + ยอดรวม + ปุ่มดูบิล (ด้านขวาเว้นที่ให้ปุ่มแชท AI)
  Widget _cartBar(BuildContext context, InvoiceFormState state) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      elevation: AppSizes.chatPanelElevation,
      shadowColor: AppColors.shadow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceMedium,
            AppSizes.spaceMedium,
            AppSizes.chatLauncherSpace,
            AppSizes.spaceMedium,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('sell.bill_count'.trParams({'count': '${state.itemCount}'}), style: textTheme.bodySmall),
                    Text(
                      MoneyUtil.format(state.amounts.total),
                      style: textTheme.titleLarge?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // ปุ่มได้ที่มากกว่ายอดรวม (flex 2) / ที่ไม่พอ คำบนปุ่มหดเป็น ... ไม่ล้นจอ
              Flexible(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => _openBillSheet(context),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text('sell.view_bill_pay'.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // เปิดบิลทับทั้งจอ (root navigator → ทับปุ่มแชท AI ด้วย) / กดรับเงิน = ปิดบิลก่อนแล้วเปิดหน้าต่างรับเงิน
  Future<void> _openBillSheet(BuildContext context) {
    final bloc = context.read<InvoiceFormBloc>();
    final height = MediaQuery.sizeOf(context).height * AppSizes.sellSheetHeightRatio;
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder:
          (sheetContext) => BlocProvider.value(
            value: bloc,
            child: SafeArea(
              child: SizedBox(
                height: height,
                child: _billPanel(
                  onClose: () => Navigator.pop(sheetContext),
                  onPay: () {
                    Navigator.pop(sheetContext);
                    _onPay();
                  },
                ),
              ),
            ),
          ),
    );
  }

  // ฝั่งสินค้า: ช่องค้นหา / สแกน + ปุ่มกรองหมวด (ติดด้านบน) + การ์ดสินค้า (เลื่อนได้)
  Widget _productPane(BuildContext context, InvoiceFormState state) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.all(AppSizes.spaceMedium), child: _searchField(context)),
          if (state.productCategories.isNotEmpty) _categoryChips(state.productCategories),
          Expanded(child: _productGrid(context, state)),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      autofocus: !isMobile,
      onChanged: _onQueryChanged,
      onSubmitted: _onCodeSubmitted,
      decoration: InputDecoration(
        hintText: 'sell.search_hint'.tr,
        prefixIcon: const Icon(Icons.qr_code_scanner),
        suffixIcon:
            _query.isEmpty
                ? null
                : IconButton(
                  tooltip: 'common.clear'.tr,
                  onPressed: () {
                    _searchController.clear();
                    _onQueryChanged('');
                  },
                  icon: const Icon(Icons.close),
                ),
      ),
    );
  }

  Widget _categoryChips(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceMedium, 0, AppSizes.spaceMedium, AppSizes.spaceSmall),
      child: Row(
        children: [
          for (final category in ['', ...categories])
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.spaceSmall),
              child: ChoiceChip(
                label: Text(category.isEmpty ? 'product.all_categories'.tr : category),
                selected: _category == category,
                onSelected: (_) => _onCategoryChanged(category),
              ),
            ),
        ],
      ),
    );
  }

  Widget _productGrid(BuildContext context, InvoiceFormState state) {
    final products = state.productsMatching(_query, category: _category);
    if (products.isEmpty) return EmptyView(message: 'product.not_found'.tr, icon: Icons.search_off);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceMedium,
        AppSizes.spaceSmall,
        AppSizes.spaceMedium,
        AppSizes.spaceMedium,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = _tileWidth(constraints.maxWidth);
          return Wrap(
            spacing: AppSizes.spaceSmall,
            runSpacing: AppSizes.spaceSmall,
            children: [for (final product in products) _productTile(context, state, product, tileWidth)],
          );
        },
      ),
    );
  }

  double _tileWidth(double areaWidth) {
    final columns = (areaWidth / AppSizes.sellTileWidth).floor().clamp(2, 6);
    return (areaWidth - AppSizes.spaceSmall * (columns - 1)) / columns;
  }

  Widget _productTile(BuildContext context, InvoiceFormState state, ProductModel product, double width) {
    final stockText =
        product.trackStock ? 'invoice.in_stock'.trParams({'stock': '${product.stock}'}) : 'product.no_stock'.tr;
    return SellProductTile(
      width: width,
      image: ProductImage(product: product, height: AppSizes.sellTileImageHeight),
      name: product.name,
      price: product.sellPrice,
      stockText: stockText,
      isOut: product.trackStock && product.stock <= 0,
      quantityInCart: state.quantityOf(product.id),
      onTap: () => context.read<InvoiceFormBloc>().add(InvoiceItemAdded(product.id)),
    );
  }

  Future<bool> _showSoldDialog(BuildContext context, InvoiceModel invoice) async {
    final change = CashUtil.change(_received, invoice.total);
    final message = 'sell.sold_message_change'.trParams({
      'no': invoice.invoiceNo,
      'total': MoneyUtil.format(invoice.total),
      'received': MoneyUtil.format(_received),
      'change': MoneyUtil.format(change < 0 ? 0 : change),
    });
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AppAlertDialog(
            isDanger: false,
            icon: Icons.check_rounded,
            title: 'sell.sold_title'.tr,
            message: message,
            secondaryText: 'sell.view_bill'.tr,
            onSecondary: () => Navigator.pop(dialogContext, true),
            primaryText: 'sell.next_sale'.tr,
            onPrimary: () => Navigator.pop(dialogContext, false),
          ),
    );
    return result ?? false;
  }
}

part of 'invoice_form_page.dart';

extension _InvoiceFormPageExt on _InvoiceFormPageState {
  Widget _backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => context.go(AppRoutes.invoices),
        icon: const Icon(Icons.arrow_back),
        label: Text('common.back'.tr),
      ),
    );
  }

  Widget _taxIdBanner(BuildContext context) {
    return NoticeBanner(
      message: 'invoice.tax_id_missing'.tr,
      actionLabel: 'invoice.go_settings'.tr,
      onAction: () => context.go(AppRoutes.settings),
    );
  }

  Widget _customerSection(BuildContext context, InvoiceFormState state) {
    return SectionCard(
      title: 'invoice.form_customer'.tr,
      subtitle: state.needsCustomerName ? null : 'invoice.customer_optional'.tr,
      child: LayoutBuilder(
        builder: (context, constraints) => _customerFields(context, constraints, state.needsCustomerName),
      ),
    );
  }

  Widget _customerFields(BuildContext context, BoxConstraints constraints, bool needsCustomerName) {
    final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
    final halfWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - AppSizes.spaceMedium) / 2;
    return Wrap(
      spacing: AppSizes.spaceMedium,
      runSpacing: AppSizes.spaceMedium,
      children: [
        SizedBox(
          width: halfWidth,
          child: AppTextField(
            label: 'invoice.customer_name'.tr,
            controller: _nameController,
            validator: needsCustomerName ? ValidatorUtil.required : null,
          ),
        ),
        SizedBox(
          width: halfWidth,
          child: AppTextField(
            label: 'invoice.issue_date'.tr,
            controller: _dateController,
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _pickDate,
          ),
        ),
        SizedBox(
          width: halfWidth,
          child: AppTextField(
            label: 'invoice.customer_tax_id'.tr,
            hint: 'settings.tax_id_hint'.tr,
            controller: _taxIdController,
            keyboardType: TextInputType.number,
            validator: ValidatorUtil.taxId,
          ),
        ),
        SizedBox(
          width: halfWidth,
          child: AppTextField(
            label: 'invoice.customer_branch'.tr,
            hint: 'settings.branch_hint'.tr,
            controller: _branchController,
          ),
        ),
        AppTextField(label: 'invoice.customer_address'.tr, controller: _addressController, maxLines: 2),
      ],
    );
  }

  Widget _itemsSection(BuildContext context, InvoiceFormState state) {
    final bloc = context.read<InvoiceFormBloc>();
    return SectionCard(
      title: 'invoice.form_items'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdown<String>(
            label: 'invoice.add_item'.tr,
            hint: 'invoice.choose_product'.tr,
            value: _productToAdd,
            items: {
              for (final product in state.products)
                product.id: '${product.name}  ·  ${MoneyUtil.format(product.sellPrice)}',
            },
            onChanged: _addProduct,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          if (state.items.isEmpty) EmptyView(message: 'invoice.items_empty'.tr, icon: Icons.add_shopping_cart),
          for (final item in state.items)
            InvoiceItemRow(
              key: ValueKey(item.productId),
              item: item,
              onChanged:
                  (quantity, unitPrice) =>
                      bloc.add(InvoiceItemChanged(productId: item.productId, quantity: quantity, unitPrice: unitPrice)),
              onRemove: () => bloc.add(InvoiceItemRemoved(item.productId)),
            ),
        ],
      ),
    );
  }

  Widget _totalsSection(BuildContext context, InvoiceFormState state) {
    final amounts = state.amounts;
    final isVat = state.company.vatRegistered;
    return SectionCard(
      title: 'invoice.grand_total'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _totalLine(context, 'invoice.items_total'.tr, amounts.itemsTotal),
          _discountField(context),
          if (isVat) _totalLine(context, 'invoice.subtotal'.tr, amounts.subtotal),
          if (isVat) _totalLine(context, 'invoice.vat'.tr, amounts.vat),
          const Divider(),
          _totalLine(context, 'invoice.grand_total'.tr, amounts.total, isBig: true),
          if (isVat && state.company.pricesIncludeVat)
            Text('invoice.prices_include_vat'.tr, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(label: 'common.note'.tr, hint: 'invoice.note_hint'.tr, controller: _noteController),
          const SizedBox(height: AppSizes.spaceLarge),
          Text('invoice.submit_note'.tr, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.spaceSmall),
          AppButton(
            text: isVat ? 'invoice.submit'.tr : 'invoice.submit_receipt'.tr,
            isLoading: state.submitStatus == AppStatus.loading,
            onPressed: state.items.isEmpty ? null : _onSubmit,
          ),
        ],
      ),
    );
  }

  Widget _discountField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSmall),
      child: Row(
        children: [
          Expanded(child: Text('invoice.discount'.tr, style: Theme.of(context).textTheme.bodyMedium)),
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
    );
  }

  Widget _totalLine(BuildContext context, String label, double value, {bool isBig = false}) {
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = isBig ? textTheme.titleLarge?.copyWith(color: AppColors.primary) : textTheme.titleSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Row(
        children: [
          Expanded(child: Text(label, style: isBig ? textTheme.titleMedium : textTheme.bodyMedium)),
          Text(MoneyUtil.format(value), style: valueStyle),
        ],
      ),
    );
  }
}

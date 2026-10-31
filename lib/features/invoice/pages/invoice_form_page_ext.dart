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

  Widget _customerSection(BuildContext context) {
    return SectionCard(title: 'invoice.form_customer'.tr, child: LayoutBuilder(builder: _customerFields));
  }

  Widget _customerFields(BuildContext context, BoxConstraints constraints) {
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
            validator: ValidatorUtil.required,
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
    final totals = state.totals;
    return SectionCard(
      title: 'invoice.grand_total'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _totalLine(context, 'invoice.subtotal'.tr, totals.subtotal),
          _totalLine(context, 'invoice.vat'.tr, totals.vat),
          const Divider(),
          _totalLine(context, 'invoice.grand_total'.tr, totals.total, isBig: true),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(label: 'common.note'.tr, hint: 'invoice.note_hint'.tr, controller: _noteController),
          const SizedBox(height: AppSizes.spaceLarge),
          Text('invoice.submit_note'.tr, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.spaceSmall),
          AppButton(
            text: 'invoice.submit'.tr,
            isLoading: state.submitStatus == AppStatus.loading,
            onPressed: state.items.isEmpty ? null : _onSubmit,
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

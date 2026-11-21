part of 'invoice_form_page.dart';

extension _InvoiceFormPageExt on _InvoiceFormPageState {
  Widget _backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
        child: TextButton.icon(
          onPressed: () => context.go(AppRoutes.invoices),
          icon: const Icon(Icons.arrow_back),
          label: Text('common.back'.tr),
        ),
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
      child: DocumentCustomerFields(
        nameController: _nameController,
        taxIdController: _taxIdController,
        branchController: _branchController,
        addressController: _addressController,
        isNameRequired: state.needsCustomerName,
        dateFields: [
          AppTextField(
            label: 'invoice.issue_date'.tr,
            controller: _dateController,
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }

  Widget _itemsSection(BuildContext context, InvoiceFormState state) {
    final bloc = context.read<InvoiceFormBloc>();
    return SectionCard(
      title: 'invoice.form_items'.tr,
      child: DraftItemsEditor(
        products: state.products,
        items: state.items,
        selectedProductId: _productToAdd,
        onAdd: _addProduct,
        onChanged:
            (productId, quantity, unitPrice) =>
                bloc.add(InvoiceItemChanged(productId: productId, quantity: quantity, unitPrice: unitPrice)),
        onRemove: (productId) => bloc.add(InvoiceItemRemoved(productId)),
      ),
    );
  }

  Widget _totalsSection(BuildContext context, InvoiceFormState state) {
    final isVat = state.company.vatRegistered;
    return SectionCard(
      title: 'invoice.grand_total'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DocumentTotalsSummary(
            amounts: state.amounts,
            showVat: isVat,
            pricesIncludeVat: state.company.pricesIncludeVat,
            discountController: _discountController,
            onDiscountChanged: (discount) => context.read<InvoiceFormBloc>().add(InvoiceDiscountChanged(discount)),
          ),
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
}

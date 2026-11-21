part of 'quotation_form_page.dart';

extension _QuotationFormPageExt on _QuotationFormPageState {
  Widget _backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
        child: TextButton.icon(
          onPressed: () => context.go(AppRoutes.quotations),
          icon: const Icon(Icons.arrow_back),
          label: Text('common.back'.tr),
        ),
      ),
    );
  }

  Widget _customerSection(BuildContext context) {
    return SectionCard(
      title: 'invoice.form_customer'.tr,
      child: DocumentCustomerFields(
        nameController: _nameController,
        taxIdController: _taxIdController,
        branchController: _branchController,
        addressController: _addressController,
        dateFields: [
          AppTextField(
            label: 'invoice.issue_date'.tr,
            controller: _issueDateController,
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _pickIssueDate,
          ),
          AppTextField(
            label: 'quotation.valid_until'.tr,
            controller: _validUntilController,
            icon: Icons.event_available_outlined,
            readOnly: true,
            onTap: _pickValidUntil,
          ),
        ],
      ),
    );
  }

  Widget _itemsSection(BuildContext context, QuotationFormState state) {
    final bloc = context.read<QuotationFormBloc>();
    return SectionCard(
      title: 'invoice.form_items'.tr,
      child: DraftItemsEditor(
        products: state.products,
        items: state.items,
        selectedProductId: _productToAdd,
        showStock: false,
        onAdd: _addProduct,
        onChanged:
            (productId, quantity, unitPrice) =>
                bloc.add(QuotationItemChanged(productId: productId, quantity: quantity, unitPrice: unitPrice)),
        onRemove: (productId) => bloc.add(QuotationItemRemoved(productId)),
      ),
    );
  }

  Widget _totalsSection(BuildContext context, QuotationFormState state) {
    return SectionCard(
      title: 'invoice.grand_total'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DocumentTotalsSummary(
            amounts: state.amounts,
            showVat: state.company.vatRegistered,
            pricesIncludeVat: state.company.pricesIncludeVat,
            discountController: _discountController,
            onDiscountChanged: (discount) => context.read<QuotationFormBloc>().add(QuotationDiscountChanged(discount)),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(label: 'common.note'.tr, hint: 'quotation.note_hint'.tr, controller: _noteController),
          const SizedBox(height: AppSizes.spaceLarge),
          Text('quotation.submit_note'.tr, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.spaceSmall),
          AppButton(
            text: 'quotation.create'.tr,
            isLoading: state.submitStatus == AppStatus.loading,
            onPressed: state.items.isEmpty ? null : _onSubmit,
          ),
        ],
      ),
    );
  }
}

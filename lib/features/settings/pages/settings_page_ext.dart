part of 'settings_page.dart';

extension _SettingsPageExt on _SettingsPageState {
  Widget _companySection(BuildContext context, SettingsState state) {
    return SectionCard(
      title: 'settings.company_title'.tr,
      subtitle: 'settings.company_subtitle'.tr,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.company.needsTaxId) NoticeBanner(message: 'settings.tax_id_missing'.tr),
            AppTextField(label: 'settings.name'.tr, controller: _nameController, validator: ValidatorUtil.required),
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(label: 'settings.address'.tr, controller: _addressController, maxLines: 3),
            const SizedBox(height: AppSizes.spaceMedium),
            _taxRow(),
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(label: 'settings.phone'.tr, controller: _phoneController, keyboardType: TextInputType.phone),
            const Divider(height: AppSizes.spaceXLarge),
            _shopTypeSwitches(context),
            const SizedBox(height: AppSizes.spaceLarge),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                text: 'common.save'.tr,
                isLoading: state.saveStatus == AppStatus.loading,
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taxRow() {
    return Wrap(
      spacing: AppSizes.spaceMedium,
      runSpacing: AppSizes.spaceMedium,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: AppTextField(
            label: 'settings.tax_id'.tr,
            hint: 'settings.tax_id_hint'.tr,
            controller: _taxIdController,
            keyboardType: TextInputType.number,
            validator: ValidatorUtil.taxId,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: AppTextField(
            label: 'settings.branch'.tr,
            hint: 'settings.branch_hint'.tr,
            controller: _branchController,
          ),
        ),
      ],
    );
  }

  Widget _shopTypeSwitches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('settings.shop_type_title'.tr, style: Theme.of(context).textTheme.titleMedium),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('settings.vat_registered'.tr),
          subtitle: Text(_vatRegistered ? 'settings.vat_registered_on'.tr : 'settings.vat_registered_off'.tr),
          value: _vatRegistered,
          onChanged: _setVatRegistered,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('settings.prices_include_vat'.tr),
          subtitle: Text('settings.prices_include_vat_hint'.tr),
          value: _vatRegistered && _pricesIncludeVat,
          onChanged: _vatRegistered ? _setPricesIncludeVat : null,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('settings.use_cost_page'.tr),
          subtitle: Text('settings.use_cost_page_hint'.tr),
          value: _useCostPage,
          onChanged: _setUseCostPage,
        ),
      ],
    );
  }

  Widget _fieldsSection(BuildContext context, SettingsState state) {
    return SectionCard(
      title: 'settings.fields_title'.tr,
      subtitle: 'settings.fields_subtitle'.tr,
      trailing: TextButton.icon(
        onPressed:
            () => ProductFieldDialog.show(context, const ProductFieldModel(name: '', type: ProductFieldModel.text)),
        icon: const Icon(Icons.add),
        label: Text('settings.field_add'.tr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.fields.isEmpty) Text('settings.fields_empty'.tr, style: Theme.of(context).textTheme.bodySmall),
          for (final field in state.fields) _fieldRow(context, field),
        ],
      ),
    );
  }

  Widget _fieldRow(BuildContext context, ProductFieldModel field) {
    final textTheme = Theme.of(context).textTheme;
    final detail =
        field.options.isEmpty
            ? 'settings.field_type.${field.type}'.tr
            : '${'settings.field_type.${field.type}'.tr}: ${field.options.join(', ')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(field.name, style: textTheme.titleSmall), Text(detail, style: textTheme.bodySmall)],
            ),
          ),
          if (field.showInList)
            AppBadge(
              text: 'settings.field_in_list'.tr,
              color: AppColors.textPrimary,
              backgroundColor: AppColors.neutralSoft,
            ),
          IconButton(
            tooltip: 'common.edit'.tr,
            onPressed: () => ProductFieldDialog.show(context, field),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'common.delete'.tr,
            onPressed: () => _confirmDeleteField(context, field),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteField(BuildContext context, ProductFieldModel field) async {
    final bloc = context.read<SettingsBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'settings.field_delete_title'.tr,
      message: 'settings.field_delete_message'.trParams({'name': field.name}),
      confirmText: 'common.delete'.tr,
    );
    if (isConfirmed) bloc.add(ProductFieldDeleted(field.id));
  }

  Widget _logoSection(BuildContext context) {
    return SectionCard(
      title: 'settings.logo_title'.tr,
      child: Row(
        children: [
          const ShopLogo(size: AppSizes.logoSize, radius: AppSizes.radiusLarge),
          const SizedBox(width: AppSizes.spaceMedium),
          Expanded(
            child: Text(
              'settings.logo_hint'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageSection(BuildContext context) {
    return SectionCard(
      title: 'settings.language_title'.tr,
      child: Align(
        alignment: Alignment.centerLeft,
        child: BlocBuilder<LanguageBloc, String>(
          builder:
              (context, langCode) => SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'th', label: Text('settings.language_th'.tr)),
                  ButtonSegment(value: 'en', label: Text('settings.language_en'.tr)),
                ],
                selected: {langCode},
                onSelectionChanged: (selected) => context.read<LanguageBloc>().add(ChangeLanguage(selected.first)),
              ),
        ),
      ),
    );
  }
}

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
            if (!state.company.hasTaxId) NoticeBanner(message: 'settings.tax_id_missing'.tr),
            AppTextField(
              label: 'settings.name'.tr,
              controller: _nameController,
              validator: ValidatorUtil.required,
            ),
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(label: 'settings.address'.tr, controller: _addressController, maxLines: 3),
            const SizedBox(height: AppSizes.spaceMedium),
            _taxRow(),
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(
              label: 'settings.phone'.tr,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
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
          builder: (context, langCode) => SegmentedButton<String>(
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/lang/language_bloc.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/settings/widgets/ai_key_section.dart';
import 'package:costbook/features/settings/widgets/product_field_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';

part 'settings_page_ext.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _branchController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _vatRegistered = true;
  bool _pricesIncludeVat = false;
  bool _useCostPage = true;

  @override
  void initState() {
    super.initState();
    _fillForm(context.read<SettingsBloc>().state.company);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _branchController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fillForm(CompanyModel company) {
    _nameController.text = company.name;
    _addressController.text = company.address;
    _taxIdController.text = company.taxId;
    _branchController.text = company.branch;
    _phoneController.text = company.phone;
    _vatRegistered = company.vatRegistered;
    _pricesIncludeVat = company.pricesIncludeVat;
    _useCostPage = company.useCostPage;
  }

  void _setVatRegistered(bool value) => setState(() => _vatRegistered = value);

  void _setPricesIncludeVat(bool value) => setState(() => _pricesIncludeVat = value);

  void _setUseCostPage(bool value) => setState(() => _useCostPage = value);

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final bloc = context.read<SettingsBloc>();
    bloc.add(
      CompanySaved(
        CompanyModel(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          taxId: _taxIdController.text.trim(),
          branch: _branchController.text.trim(),
          phone: _phoneController.text.trim(),
          hasLogo: bloc.state.company.hasLogo,
          vatRegistered: _vatRegistered,
          pricesIncludeVat: _vatRegistered && _pricesIncludeVat,
          useCostPage: _useCostPage,
        ),
      ),
    );
  }

  void _onResult(BuildContext context, AppStatus status, String errorCode) {
    if (status == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'common.saved'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.$errorCode'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) => previous.status != current.status && current.status == AppStatus.success,
          listener: (context, state) => setState(() => _fillForm(state.company)),
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen:
              (previous, current) =>
                  previous.saveStatus == AppStatus.loading && current.saveStatus != AppStatus.loading,
          listener: (context, state) => _onResult(context, state.saveStatus, state.saveErrorCode),
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen:
              (previous, current) =>
                  previous.fieldStatus == AppStatus.loading && current.fieldStatus != AppStatus.loading,
          listener: (context, state) => _onResult(context, state.fieldStatus, state.fieldErrorCode),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return PageContent(
            maxWidth: AppSizes.contentMaxWidth * 2 / 3,
            centerChild: _stateView(context, state),
            children: [
              if (state.status == AppStatus.success) ...[
                _companySection(context, state),
                _fieldsSection(context, state),
                const AiKeySection(),
                _logoSection(context),
                _languageSection(context),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget? _stateView(BuildContext context, SettingsState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<SettingsBloc>().add(SettingsRequested()),
      );
    }
    return null;
  }
}

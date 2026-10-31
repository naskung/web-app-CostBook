import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/lang/language_bloc.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
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
  }

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
        ),
      ),
    );
  }

  void _onSaveResult(BuildContext context, SettingsState state) {
    if (state.saveStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'common.saved'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.saveErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) => previous.status != current.status && current.status == AppStatus.success,
          listener: (context, state) => _fillForm(state.company),
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) =>
              previous.saveStatus == AppStatus.loading && current.saveStatus != AppStatus.loading,
          listener: _onSaveResult,
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
          if (state.status == AppStatus.failure) {
            return ErrorView(
              message: 'error.${state.errorCode}'.tr,
              retryLabel: 'common.retry'.tr,
              onRetry: () => context.read<SettingsBloc>().add(SettingsRequested()),
            );
          }
          return PageContent(
            maxWidth: AppSizes.contentMaxWidth * 2 / 3,
            children: [
              _companySection(context, state),
              _logoSection(context),
              _languageSection(context),
            ],
          );
        },
      ),
    );
  }
}

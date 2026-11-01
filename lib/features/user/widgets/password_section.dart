import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';

// เปลี่ยนรหัสผ่านของตัวเอง: ต้องใส่รหัสเดิมให้ถูก / เปลี่ยนสำเร็จแล้วล้างช่องให้
class PasswordSection extends StatefulWidget {
  const PasswordSection({super.key});

  @override
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    context.read<ProfileBloc>().add(
      PasswordChanged(currentPassword: _currentController.text, newPassword: _newController.text),
    );
  }

  void _onResult(BuildContext context, ProfileState state) {
    if (state.passwordStatus == AppStatus.failure) {
      SnackbarHelper.showError(context, 'error.${state.passwordErrorCode}'.tr);
      return;
    }
    _currentController.clear();
    _newController.clear();
    _confirmController.clear();
    SnackbarHelper.showSuccess(context, 'profile.password_changed'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen:
          (previous, current) =>
              previous.passwordStatus == AppStatus.loading && current.passwordStatus != AppStatus.loading,
      listener: _onResult,
      buildWhen: (previous, current) => previous.passwordStatus != current.passwordStatus,
      builder: (context, state) {
        return SectionCard(
          title: 'profile.password_title'.tr,
          subtitle: 'profile.password_hint'.trParams({'min': '${ValidatorUtil.minPasswordLength}'}),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'profile.current_password'.tr,
                  controller: _currentController,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  validator: ValidatorUtil.required,
                ),
                const SizedBox(height: AppSizes.spaceMedium),
                AppTextField(
                  label: 'profile.new_password'.tr,
                  controller: _newController,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: ValidatorUtil.password,
                ),
                const SizedBox(height: AppSizes.spaceMedium),
                AppTextField(
                  label: 'profile.confirm_password'.tr,
                  controller: _confirmController,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => ValidatorUtil.passwordMatch(value, _newController.text),
                  onSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: AppSizes.spaceLarge),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    text: 'profile.change_password'.tr,
                    icon: Icons.lock_outline,
                    isLoading: state.passwordStatus == AppStatus.loading,
                    onPressed: _onSave,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

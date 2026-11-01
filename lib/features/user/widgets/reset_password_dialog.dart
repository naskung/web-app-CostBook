import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/user/bloc/user_list_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

// เจ้าของร้านตั้งรหัสผ่านใหม่ให้ผู้ใช้ (เช่น พนักงานลืมรหัส) — ไม่ต้องรู้รหัสเดิม
class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key, required this.user});

  final UserModel user;

  static Future<void> show(BuildContext context, UserModel user) {
    final bloc = context.read<UserListBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: ResetPasswordDialog(user: user)),
    );
  }

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    context.read<UserListBloc>().add(UserPasswordReset(id: widget.user.id, password: _passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserListBloc, UserListState>(
      listenWhen:
          (previous, current) => previous.resetStatus == AppStatus.loading && current.resetStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.resetStatus == AppStatus.failure;
        return FormDialog(
          title: 'user.reset_password'.tr,
          subtitle: 'user.reset_password_hint'.trParams({'name': widget.user.displayName}),
          icon: Icons.lock_reset,
          saveLabel: 'common.save'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.resetStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.resetErrorCode}'.tr : '',
          onSave: _onSave,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'profile.new_password'.tr,
                  hint: 'user.first_password_hint'.trParams({'min': '${ValidatorUtil.minPasswordLength}'}),
                  controller: _passwordController,
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
                  validator: (value) => ValidatorUtil.passwordMatch(value, _passwordController.text),
                  onSubmitted: (_) => _onSave(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

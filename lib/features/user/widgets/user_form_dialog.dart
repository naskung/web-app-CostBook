import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/user/bloc/user_list_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

// เพิ่มผู้ใช้ (อีเมล + รหัสแรก) / แก้ชื่อ-role-เปิดปิดบัญชี
// isSelf = แก้บัญชีตัวเอง → เปลี่ยน role / ปิดบัญชีไม่ได้ (กันเจ้าของร้านล็อกตัวเองออก)
class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, required this.user, required this.isSelf});

  final UserModel user;
  final bool isSelf;

  static Future<void> show(BuildContext context, UserModel user, {bool isSelf = false}) {
    final bloc = context.read<UserListBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: UserFormDialog(user: user, isSelf: isSelf)),
    );
  }

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.user.email);
  late final _firstNameController = TextEditingController(text: widget.user.firstName);
  late final _lastNameController = TextEditingController(text: widget.user.lastName);
  final _passwordController = TextEditingController();
  late UserRole _role = widget.user.role;
  late bool _isActive = widget.user.isActive;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    final user = UserModel(
      id: widget.user.id,
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      role: _role,
      isActive: _isActive,
    );
    context.read<UserListBloc>().add(UserSaved(user, password: _passwordController.text));
  }

  void _setRole(UserRole? role) => setState(() => _role = role ?? _role);

  void _setActive(bool value) => setState(() => _isActive = value);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserListBloc, UserListState>(
      listenWhen:
          (previous, current) => previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.saveStatus == AppStatus.failure;
        return FormDialog(
          title: widget.user.isNew ? 'user.add'.tr : 'user.edit'.tr,
          subtitle: widget.user.isNew ? 'user.add_hint'.tr : '',
          icon: Icons.person_outline,
          saveLabel: 'common.save'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.saveStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.saveErrorCode}'.tr : '',
          onSave: _onSave,
          child: Form(key: _formKey, child: _fields(context)),
        );
      },
    );
  }

  Widget _fields(BuildContext context) {
    final isNew = widget.user.isNew;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'profile.email'.tr,
          controller: _emailController,
          readOnly: !isNew,
          keyboardType: TextInputType.emailAddress,
          validator: isNew ? ValidatorUtil.email : null,
        ),
        const SizedBox(height: AppSizes.spaceMedium),
        AppTextField(
          label: 'profile.first_name'.tr,
          controller: _firstNameController,
          validator: ValidatorUtil.required,
        ),
        const SizedBox(height: AppSizes.spaceMedium),
        AppTextField(label: 'profile.last_name'.tr, controller: _lastNameController),
        const SizedBox(height: AppSizes.spaceMedium),
        if (isNew) ...[
          AppTextField(
            label: 'user.first_password'.tr,
            hint: 'user.first_password_hint'.trParams({'min': '${ValidatorUtil.minPasswordLength}'}),
            controller: _passwordController,
            isPassword: true,
            autofillHints: const [AutofillHints.newPassword],
            validator: ValidatorUtil.password,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
        ],
        AppDropdown<UserRole>(
          label: 'user.role'.tr,
          value: _role,
          items: {for (final role in UserRole.values) role: role.labelKey.tr},
          onChanged: widget.isSelf ? null : _setRole,
        ),
        const SizedBox(height: AppSizes.spaceSmall),
        Text('user.role_hint'.tr, style: Theme.of(context).textTheme.bodySmall),
        if (!isNew)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('user.active'.tr),
            subtitle: Text('user.active_hint'.tr),
            value: _isActive,
            onChanged: widget.isSelf ? null : _setActive,
          ),
        if (widget.isSelf)
          Text(
            'user.self_hint'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }
}

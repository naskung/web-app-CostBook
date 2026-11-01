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

// แก้ชื่อ-นามสกุลของตัวเอง (อีเมลใช้ login แก้ไม่ได้)
class ProfileInfoSection extends StatefulWidget {
  const ProfileInfoSection({super.key});

  @override
  State<ProfileInfoSection> createState() => _ProfileInfoSectionState();
}

class _ProfileInfoSectionState extends State<ProfileInfoSection> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileBloc>().state.user;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    context.read<ProfileBloc>().add(
      ProfileSaved(firstName: _firstNameController.text.trim(), lastName: _lastNameController.text.trim()),
    );
  }

  void _onResult(BuildContext context, ProfileState state) {
    if (state.saveStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'common.saved'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.saveErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen:
          (previous, current) => previous.saveStatus == AppStatus.loading && current.saveStatus != AppStatus.loading,
      listener: _onResult,
      buildWhen: (previous, current) => previous.saveStatus != current.saveStatus,
      builder: (context, state) {
        return SectionCard(
          title: 'profile.info_title'.tr,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'profile.first_name'.tr,
                  controller: _firstNameController,
                  validator: ValidatorUtil.required,
                  onSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: AppSizes.spaceMedium),
                AppTextField(
                  label: 'profile.last_name'.tr,
                  controller: _lastNameController,
                  onSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: AppSizes.spaceMedium),
                AppTextField(label: 'profile.email'.tr, controller: _emailController, readOnly: true),
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
      },
    );
  }
}

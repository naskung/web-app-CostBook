import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

class ProductFieldDialog extends StatefulWidget {
  const ProductFieldDialog({super.key, required this.field});

  final ProductFieldModel field;

  static Future<void> show(BuildContext context, ProductFieldModel field) {
    final bloc = context.read<SettingsBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: ProductFieldDialog(field: field)),
    );
  }

  @override
  State<ProductFieldDialog> createState() => _ProductFieldDialogState();
}

class _ProductFieldDialogState extends State<ProductFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.field.name);
  late final _optionsController = TextEditingController(text: widget.field.options.join(', '));
  late String _type = widget.field.type;
  late bool _showInList = widget.field.showInList;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  List<String> _options() {
    return _optionsController.text
        .split(',')
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toList();
  }

  String? _validateOptions(String? value) {
    if (_type != ProductFieldModel.select) return null;
    if (_options().isEmpty) return 'settings.field_options_required'.tr;
    return null;
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    final bloc = context.read<SettingsBloc>();
    final field = ProductFieldModel(
      id: widget.field.id,
      name: _nameController.text.trim(),
      type: _type,
      options: _type == ProductFieldModel.select ? _options() : const [],
      showInList: _showInList,
      sortOrder: widget.field.isNew ? bloc.state.fields.length + 1 : widget.field.sortOrder,
    );
    bloc.add(ProductFieldSaved(field));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen:
          (previous, current) => previous.fieldStatus == AppStatus.loading && current.fieldStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.fieldStatus == AppStatus.failure;
        return FormDialog(
          title: widget.field.isNew ? 'settings.field_add'.tr : 'settings.field_edit'.tr,
          saveLabel: 'common.save'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.fieldStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.fieldErrorCode}'.tr : '',
          onSave: _onSave,
          child: _form(),
        );
      },
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'settings.field_name'.tr,
            hint: 'settings.field_name_hint'.tr,
            controller: _nameController,
            validator: ValidatorUtil.required,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppDropdown<String>(
            label: 'settings.field_type'.tr,
            value: _type,
            items: {for (final type in ProductFieldModel.types) type: 'settings.field_type.$type'.tr},
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          if (_type == ProductFieldModel.select) ...[
            const SizedBox(height: AppSizes.spaceMedium),
            AppTextField(
              label: 'settings.field_options'.tr,
              hint: 'settings.field_options_hint'.tr,
              controller: _optionsController,
              validator: _validateOptions,
            ),
          ],
          const SizedBox(height: AppSizes.spaceSmall),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('settings.field_show_in_list'.tr),
            value: _showInList,
            onChanged: (value) => setState(() => _showInList = value),
          ),
        ],
      ),
    );
  }
}

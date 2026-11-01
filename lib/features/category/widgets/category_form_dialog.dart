import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/category/bloc/category_bloc.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

// เพิ่ม / เปลี่ยนชื่อหมวด (บันทึกสำเร็จแล้วปิดเอง)
class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({super.key, required this.category});

  final ProductCategoryModel category;

  static Future<void> show(BuildContext context, ProductCategoryModel category) {
    final bloc = context.read<CategoryBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: CategoryFormDialog(category: category)),
    );
  }

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.category.name);
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    final category = ProductCategoryModel(id: widget.category.id, name: _nameController.text.trim());
    context.read<CategoryBloc>().add(CategorySaved(category));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listenWhen:
          (previous, current) => previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.saveStatus == AppStatus.failure;
        return FormDialog(
          title: widget.category.isNew ? 'category.add'.tr : 'category.edit'.tr,
          subtitle: widget.category.isNew ? '' : 'category.edit_hint'.tr,
          icon: Icons.category_outlined,
          saveLabel: 'common.save'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.saveStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.saveErrorCode}'.tr : '',
          onSave: _onSave,
          child: Form(
            key: _formKey,
            child: AppTextField(
              label: 'category.name'.tr,
              hint: 'category.name_hint'.tr,
              controller: _nameController,
              validator: ValidatorUtil.required,
              onSubmitted: (_) => _onSave(),
            ),
          ),
        );
      },
    );
  }
}

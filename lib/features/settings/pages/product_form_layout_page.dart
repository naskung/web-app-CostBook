import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/form_layout_util.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/settings/widgets/form_layout_card.dart';
import 'package:costbook/features/settings/widgets/product_field_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';

// จัดหน้าฟอร์มเพิ่ม / แก้สินค้า: เห็นทุกช่องเรียงเหมือนฟอร์มจริง ลากย้ายได้ตามสบาย แล้วค่อยกดบันทึก (เปลี่ยนใจกดยกเลิก)
class ProductFormLayoutPage extends StatefulWidget {
  const ProductFormLayoutPage({super.key});

  @override
  State<ProductFormLayoutPage> createState() => _ProductFormLayoutPageState();
}

class _ProductFormLayoutPageState extends State<ProductFormLayoutPage> {
  // ลำดับที่ลากไว้แต่ยังไม่บันทึก (null = ยังไม่ได้ย้าย ใช้ลำดับที่บันทึกไว้)
  List<String>? _draft;

  List<String> _orderOf(SettingsState state) {
    return FormLayoutUtil.order(_draft ?? state.formLayout, [for (final field in state.fields) field.id]);
  }

  bool _isDirty(SettingsState state) => _draft != null && !listEquals(_orderOf(state), state.formOrder);

  void _onSettingsChanged(BuildContext context, SettingsState state) {
    if (state.layoutStatus == AppStatus.success) {
      setState(() => _draft = null);
      SnackbarHelper.showSuccess(context, 'settings.form_layout_saved'.tr);
    }
    if (state.layoutStatus == AppStatus.failure) {
      SnackbarHelper.showError(context, 'error.${state.layoutErrorCode}'.tr);
    }
  }

  void _onReorder(SettingsState state, int oldIndex, int newIndex) {
    setState(() => _draft = FormLayoutUtil.moved(_orderOf(state), oldIndex, newIndex));
  }

  void _save(SettingsState state) {
    context.read<SettingsBloc>().add(ProductFormLayoutSaved(_orderOf(state)));
  }

  void _reset() {
    setState(() => _draft = null);
  }

  Future<void> _goBack(SettingsState state) async {
    if (_isDirty(state)) {
      final isConfirmed = await DialogHelper.confirm(
        context,
        title: 'settings.form_layout_leave_title'.tr,
        message: 'settings.form_layout_leave_message'.tr,
        confirmText: 'settings.form_layout_leave'.tr,
        icon: Icons.warning_amber_rounded,
      );
      if (!isConfirmed || !mounted) return;
    }
    context.go(AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.pagePadding(context);
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) => previous.layoutStatus != current.layoutStatus,
      listener: _onSettingsChanged,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.dialogMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context, state),
                  const SizedBox(height: AppSizes.spaceMedium),
                  Expanded(child: _isLoading(state) ? const AppLoading() : _list(state)),
                  _saveBar(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isLoading(SettingsState state) => state.status == AppStatus.initial || state.status == AppStatus.loading;

  Widget _header(BuildContext context, SettingsState state) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => _goBack(state),
          icon: const Icon(Icons.arrow_back),
          label: Text('settings.form_layout_back'.tr),
        ),
        const SizedBox(height: AppSizes.spaceSmall),
        Row(
          children: [
            Expanded(child: Text('settings.form_layout_title'.tr, style: textTheme.titleLarge)),
            OutlinedButton.icon(
              onPressed:
                  () =>
                      ProductFieldDialog.show(context, const ProductFieldModel(name: '', type: ProductFieldModel.text)),
              icon: const Icon(Icons.add),
              label: Text('settings.field_add'.tr),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceXSmall),
        Text('settings.form_layout_hint'.tr, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _list(SettingsState state) {
    final order = _orderOf(state);
    final fieldsById = {for (final field in state.fields) field.id: field};
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      itemCount: order.length,
      onReorder: (oldIndex, newIndex) => _onReorder(state, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final key = order[index];
        final field = fieldsById[key];
        return FormLayoutCard(
          key: ValueKey(key),
          index: index,
          blockKey: key,
          field: field,
          onEdit: field == null ? null : () => ProductFieldDialog.show(context, field),
          onDelete: field == null ? null : () => ProductFieldDialog.confirmDelete(context, field),
        );
      },
    );
  }

  // แถบล่าง: ยังไม่ได้ย้าย = ปุ่มกดไม่ได้ / ย้ายแล้ว = บอกว่ายังไม่ได้บันทึก + ยกเลิก / บันทึก
  Widget _saveBar(BuildContext context, SettingsState state) {
    final isDirty = _isDirty(state);
    final isSaving = state.layoutStatus == AppStatus.loading;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceMedium),
      margin: const EdgeInsets.only(bottom: AppSizes.chatLauncherSpace),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Wrap(
        spacing: AppSizes.spaceSmall,
        runSpacing: AppSizes.spaceSmall,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            isDirty ? 'settings.form_layout_unsaved'.tr : 'settings.form_layout_clean'.tr,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: isDirty ? AppColors.primaryDark : AppColors.textSecondary),
          ),
          Wrap(
            spacing: AppSizes.spaceSmall,
            children: [
              OutlinedButton(
                onPressed: isDirty && !isSaving ? _reset : null,
                child: Text('settings.form_layout_reset'.tr),
              ),
              SizedBox(
                width: AppSizes.rankedLabelWidth * 1.3,
                child: AppButton(
                  text: 'settings.form_layout_save'.tr,
                  isLoading: isSaving,
                  onPressed: isDirty ? () => _save(state) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
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
import 'package:costbook/shared/widgets/atoms/app_loading.dart';

// จัดหน้าฟอร์มเพิ่ม / แก้สินค้า: เห็นทุกช่องเรียงเหมือนฟอร์มจริง ลากย้ายได้ บันทึกลำดับให้ทันที
class ProductFormLayoutPage extends StatefulWidget {
  const ProductFormLayoutPage({super.key});

  @override
  State<ProductFormLayoutPage> createState() => _ProductFormLayoutPageState();
}

class _ProductFormLayoutPageState extends State<ProductFormLayoutPage> {
  late List<String> _order = context.read<SettingsBloc>().state.formOrder;

  void _onSettingsChanged(BuildContext context, SettingsState state) {
    if (state.layoutStatus == AppStatus.failure) {
      SnackbarHelper.showError(context, 'error.${state.layoutErrorCode}'.tr);
    }
    setState(() => _order = state.formOrder);
  }

  void _onReorder(int oldIndex, int newIndex) {
    final order = FormLayoutUtil.moved(_order, oldIndex, newIndex);
    setState(() => _order = order);
    context.read<SettingsBloc>().add(ProductFormLayoutSaved(order));
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.pagePadding(context);
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen:
          (previous, current) =>
              previous.formLayout != current.formLayout ||
              previous.fields != current.fields ||
              previous.layoutStatus != current.layoutStatus,
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
          onPressed: () => context.go(AppRoutes.settings),
          icon: const Icon(Icons.arrow_back),
          label: Text('settings.form_layout_back'.tr),
        ),
        const SizedBox(height: AppSizes.spaceSmall),
        Row(
          children: [
            Expanded(child: Text('settings.form_layout_title'.tr, style: textTheme.titleLarge)),
            FilledButton.icon(
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
        const SizedBox(height: AppSizes.spaceXSmall),
        _saveStatus(context, state),
      ],
    );
  }

  Widget _saveStatus(BuildContext context, SettingsState state) {
    final style = Theme.of(context).textTheme.bodySmall;
    if (state.layoutStatus == AppStatus.loading) {
      return Text('settings.form_layout_saving'.tr, style: style?.copyWith(color: AppColors.textSecondary));
    }
    if (state.layoutStatus == AppStatus.success) {
      return Row(
        children: [
          const Icon(Icons.check_circle, size: AppSizes.badgeIcon, color: AppColors.success),
          const SizedBox(width: AppSizes.spaceXSmall),
          Text('settings.form_layout_saved'.tr, style: style?.copyWith(color: AppColors.success)),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _list(SettingsState state) {
    final fieldsById = {for (final field in state.fields) field.id: field};
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: AppSizes.chatLauncherSpace),
      itemCount: _order.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final key = _order[index];
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
}

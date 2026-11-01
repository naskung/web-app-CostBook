import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/features/category/bloc/category_bloc.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/category/widgets/category_form_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/load_more_footer.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

// หมวดหมู่สินค้า: เพิ่ม / เปลี่ยนชื่อ (สินค้าทุกตัวในหมวดเปลี่ยนตาม) / ลบ (สินค้ากลายเป็นไม่มีหมวด)
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listenWhen:
              (previous, current) =>
                  previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
          listener: (context, state) => SnackbarHelper.showSuccess(context, 'common.saved'.tr),
        ),
        BlocListener<CategoryBloc, CategoryState>(
          listenWhen:
              (previous, current) =>
                  previous.deleteStatus == AppStatus.loading && current.deleteStatus != AppStatus.loading,
          listener: (context, state) {
            if (state.deleteStatus == AppStatus.success) {
              SnackbarHelper.showSuccess(context, 'category.deleted'.tr);
              return;
            }
            SnackbarHelper.showError(context, 'error.${state.deleteErrorCode}'.tr);
          },
        ),
      ],
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          final stateView = _stateView(context, state);
          final bloc = context.read<CategoryBloc>();
          return PageContent(
            centerChild: stateView,
            onLoadMore: state.canLoadMore ? () => bloc.add(CategoriesMoreRequested()) : null,
            children: [
              _toolbar(context),
              if (stateView == null) ...[
                _table(context, state.categories),
                LoadMoreFooter(
                  status: state.moreStatus,
                  retryLabel: 'common.load_more_failed'.tr,
                  onRetry: () => bloc.add(CategoriesMoreRequested()),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => CategoryFormDialog.show(context, const ProductCategoryModel(name: '')),
          icon: const Icon(Icons.add),
          label: Text('category.add'.tr),
        ),
      ],
      children: [Text('category.subtitle'.tr, style: Theme.of(context).textTheme.bodySmall)],
    );
  }

  Widget? _stateView(BuildContext context, CategoryState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<CategoryBloc>().add(CategoriesRequested()),
      );
    }
    if (state.categories.isEmpty) return EmptyView(message: 'category.empty'.tr, icon: Icons.category_outlined);
    return null;
  }

  Widget _table(BuildContext context, List<ProductCategoryModel> categories) {
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'category.name'.tr, flex: 4),
        AppDataColumn(label: 'category.product_count'.tr, flex: 2, alignEnd: true),
        const AppDataColumn(label: '', flex: 2, alignEnd: true),
      ],
      onRowTap: (index) => CategoryFormDialog.show(context, categories[index]),
      rows: [
        for (final category in categories)
          [
            Text(category.name, style: Theme.of(context).textTheme.titleSmall),
            Text('category.count_value'.trParams({'count': '${category.productCount}'})),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'common.edit'.tr,
                  onPressed: () => CategoryFormDialog.show(context, category),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'common.delete'.tr,
                  onPressed: () => _confirmDelete(context, category),
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                ),
              ],
            ),
          ],
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProductCategoryModel category) async {
    final bloc = context.read<CategoryBloc>();
    final message =
        category.productCount > 0
            ? 'category.delete_message_used'.trParams({'name': category.name, 'count': '${category.productCount}'})
            : 'category.delete_message'.trParams({'name': category.name});
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'category.delete_title'.tr,
      message: message,
      confirmText: 'common.delete'.tr,
    );
    if (isConfirmed) bloc.add(CategoryDeleted(category.id));
  }
}

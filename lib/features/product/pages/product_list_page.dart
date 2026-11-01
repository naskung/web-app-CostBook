import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_form_dialog.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/widgets/stock_movement_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/money_text.dart';
import 'package:costbook/features/product/widgets/product_image.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/search_field.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

part 'product_list_page_ext.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listenWhen:
              (previous, current) =>
                  previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
          listener: (context, state) {
            if (state.imageErrorCode.isEmpty) {
              SnackbarHelper.showSuccess(context, 'common.saved'.tr);
              return;
            }
            final reason = 'error.${state.imageErrorCode}'.tr;
            SnackbarHelper.showError(context, 'product.image_failed'.trParams({'reason': reason}));
          },
        ),
        BlocListener<ProductBloc, ProductState>(
          listenWhen:
              (previous, current) =>
                  previous.deleteStatus == AppStatus.loading && current.deleteStatus != AppStatus.loading,
          listener: _onDeleteResult,
        ),
        // รับเข้า / เบิกออกสำเร็จ → โหลดสินค้าใหม่ให้คงเหลือในตารางตรง
        BlocListener<StockBloc, StockState>(
          listenWhen:
              (previous, current) =>
                  previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
          listener: (context, state) {
            final message = state.savedType == MovementModel.stockIn ? 'stock.saved_in' : 'stock.saved_out';
            SnackbarHelper.showSuccess(context, message.tr);
            context.read<ProductBloc>().add(ProductsRequested());
          },
        ),
      ],
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final settings = context.watch<SettingsBloc>().state;
          final stateView = _stateView(context, state);
          return PageContent(
            centerChild: stateView,
            children: [
              _toolbar(context, state, settings.fields),
              _filters(context, state),
              if (stateView == null) _table(context, state, settings),
            ],
          );
        },
      ),
    );
  }

  void _onDeleteResult(BuildContext context, ProductState state) {
    if (state.deleteStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'common.deleted'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.deleteErrorCode}'.tr);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/features/stock/widgets/stock_movement_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

part 'stock_page_ext.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockBloc, StockState>(
      listenWhen: (previous, current) =>
          previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
      listener: (context, state) => SnackbarHelper.showSuccess(
        context,
        state.savedType == MovementModel.stockIn ? 'stock.saved_in'.tr : 'stock.saved_out'.tr,
      ),
      child: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          final stateView = _stateView(context, state);
          return PageContent(
            centerChild: stateView,
            children: [
              _toolbar(context, state),
              if (stateView == null) _content(context, state),
            ],
          );
        },
      ),
    );
  }
}

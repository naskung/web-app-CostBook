import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/percent_util.dart';
import 'package:costbook/features/transaction/bloc/transaction_bloc.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/widgets/transaction_form_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/money_text.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/month_switcher.dart';
import 'package:costbook/shared/widgets/molecules/stat_card.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';
import 'package:costbook/shared/widgets/organisms/stat_grid.dart';

part 'transaction_list_page_ext.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionBloc, TransactionState>(
          listenWhen:
              (previous, current) =>
                  previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
          listener: (context, state) => SnackbarHelper.showSuccess(context, 'common.saved'.tr),
        ),
        BlocListener<TransactionBloc, TransactionState>(
          listenWhen:
              (previous, current) =>
                  previous.deleteStatus == AppStatus.loading && current.deleteStatus != AppStatus.loading,
          listener: _onDeleteResult,
        ),
      ],
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          final isLoaded = state.status == AppStatus.success;
          return PageContent(
            centerChild: _stateView(context, state),
            children: [
              _toolbar(context, state),
              if (isLoaded) _summary(state),
              if (isLoaded && state.transactions.isNotEmpty) _table(context, state.transactions),
            ],
          );
        },
      ),
    );
  }

  void _onDeleteResult(BuildContext context, TransactionState state) {
    if (state.deleteStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'common.deleted'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.deleteErrorCode}'.tr);
  }
}

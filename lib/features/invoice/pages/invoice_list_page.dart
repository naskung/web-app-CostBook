import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/invoice/bloc/invoice_list_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';
import 'package:costbook/features/invoice/widgets/delivery_status_menu.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/money_text.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/load_more_footer.dart';
import 'package:costbook/shared/widgets/molecules/month_switcher.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

part 'invoice_list_page_ext.dart';

class InvoiceListPage extends StatelessWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trackDelivery = context.watch<SettingsBloc>().state.company.trackDelivery;
    return BlocConsumer<InvoiceListBloc, InvoiceListState>(
      listenWhen:
          (previous, current) =>
              previous.deliveryUpdateStatus == AppStatus.loading && current.deliveryUpdateStatus == AppStatus.failure,
      listener: (context, state) => SnackbarHelper.showError(context, 'error.${state.deliveryErrorCode}'.tr),
      builder: (context, state) {
        final stateView = _stateView(context, state);
        final bloc = context.read<InvoiceListBloc>();
        return PageContent(
          centerChild: stateView,
          onLoadMore: state.canLoadMore ? () => bloc.add(InvoicesMoreRequested()) : null,
          children: [
            _toolbar(context, state),
            if (stateView == null) ...[
              _table(context, state.invoices, trackDelivery: trackDelivery),
              LoadMoreFooter(
                status: state.moreStatus,
                retryLabel: 'common.load_more_failed'.tr,
                onRetry: () => bloc.add(InvoicesMoreRequested()),
              ),
            ],
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/quotation/bloc/quotation_list_bloc.dart';
import 'package:costbook/features/quotation/models/quotation_summary_model.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/money_text.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/load_more_footer.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/date_range_picker.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

part 'quotation_list_page_ext.dart';

class QuotationListPage extends StatelessWidget {
  const QuotationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuotationListBloc, QuotationListState>(
      builder: (context, state) {
        final stateView = _stateView(context, state);
        final bloc = context.read<QuotationListBloc>();
        return PageContent(
          centerChild: stateView,
          onLoadMore: state.canLoadMore ? () => bloc.add(QuotationsMoreRequested()) : null,
          children: [
            _toolbar(context, state),
            if (stateView == null) ...[
              _table(context, state.quotations),
              LoadMoreFooter(
                status: state.moreStatus,
                retryLabel: 'common.load_more_failed'.tr,
                onRetry: () => bloc.add(QuotationsMoreRequested()),
              ),
            ],
          ],
        );
      },
    );
  }
}

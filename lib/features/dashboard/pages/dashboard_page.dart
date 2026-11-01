import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/percent_util.dart';
import 'package:costbook/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';
import 'package:costbook/features/dashboard/widgets/ai_ask_card.dart';
import 'package:costbook/features/dashboard/widgets/category_split.dart';
import 'package:costbook/features/dashboard/widgets/dashboard_panel.dart';
import 'package:costbook/features/dashboard/widgets/margin_gauge.dart';
import 'package:costbook/features/dashboard/widgets/monthly_trend_chart.dart';
import 'package:costbook/features/dashboard/widgets/sales_trend_chart.dart';
import 'package:costbook/features/dashboard/widgets/top_products_table.dart';
import 'package:costbook/features/dashboard/widgets/weekday_chart.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/delta_pill.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/market_range_bar.dart';
import 'package:costbook/shared/widgets/molecules/month_switcher.dart';
import 'package:costbook/shared/widgets/molecules/ranked_bar_list.dart';
import 'package:costbook/shared/widgets/molecules/stat_card.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/stat_grid.dart';

part 'dashboard_page_ext.dart';
part 'dashboard_page_charts.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoaded = state.status == AppStatus.success;
        return PageContent(
          centerChild: _stateView(context, state),
          children: [_header(context, state), if (isLoaded) _body(context, state)],
        );
      },
    );
  }
}

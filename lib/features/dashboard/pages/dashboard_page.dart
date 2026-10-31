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
import 'package:costbook/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/month_switcher.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/molecules/stat_card.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';
import 'package:costbook/shared/widgets/organisms/stat_grid.dart';

part 'dashboard_page_ext.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoaded = state.status == AppStatus.success;
        return PageContent(
          centerChild: _stateView(context, state),
          children: [
            _toolbar(context, state),
            if (isLoaded) _stats(state.dashboard),
            if (isLoaded) _quickActions(context),
            if (isLoaded) _lowStock(context, state.dashboard),
          ],
        );
      },
    );
  }
}

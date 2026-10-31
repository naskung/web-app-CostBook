import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/market_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/percent_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/market/bloc/market_bloc.dart';
import 'package:costbook/features/market/models/market_check_model.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/chart_legend.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/market_range_bar.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/molecules/stat_card.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/stat_grid.dart';

part 'market_page_ext.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final company = context.watch<SettingsBloc>().state.company;
    return BlocConsumer<MarketBloc, MarketState>(
      listenWhen: (previous, current) => previous.checkStatus != current.checkStatus,
      listener: (context, state) {
        if (state.checkStatus == AppStatus.failure) {
          SnackbarHelper.showError(context, 'error.${state.checkErrorCode}'.tr);
        }
        if (state.checkStatus == AppStatus.success) {
          SnackbarHelper.showSuccess(context, 'market.checked'.tr);
        }
      },
      builder: (context, state) {
        final product = state.product;
        final check = state.check;
        final isLoaded = state.status == AppStatus.success && product != null;
        return PageContent(
          centerChild: _stateView(context, state),
          children: [
            _backButton(context),
            if (isLoaded) _header(context, state, product, company),
            if (isLoaded && state.isChecking) _checking(context),
            if (isLoaded && check != null) ..._result(context, product, check, company),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/pdf_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/quotation/bloc/quotation_detail_bloc.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';
import 'package:costbook/features/quotation/widgets/quotation_paper.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

class QuotationDetailPage extends StatefulWidget {
  const QuotationDetailPage({super.key});

  @override
  State<QuotationDetailPage> createState() => _QuotationDetailPageState();
}

class _QuotationDetailPageState extends State<QuotationDetailPage> {
  final _paperKey = GlobalKey();

  Future<void> _confirmCancel(QuotationModel quotation) async {
    final bloc = context.read<QuotationDetailBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'quotation.cancel_title'.trParams({'no': quotation.quotationNo}),
      message: 'quotation.cancel_message'.tr,
      confirmText: 'quotation.cancel_confirm'.tr,
      icon: Icons.block,
    );
    if (isConfirmed) bloc.add(QuotationCancelRequested());
  }

  void _onCancelResult(BuildContext context, QuotationDetailState state) {
    if (state.cancelStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'quotation.cancelled_done'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.cancelErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuotationDetailBloc, QuotationDetailState>(
      listenWhen:
          (previous, current) =>
              previous.cancelStatus == AppStatus.loading && current.cancelStatus != AppStatus.loading,
      listener: _onCancelResult,
      builder: (context, state) {
        final quotation = state.quotation;
        if (state.status == AppStatus.failure) {
          return ErrorView(
            message: 'error.${state.errorCode}'.tr,
            retryLabel: 'common.retry'.tr,
            onRetry: () => context.read<QuotationDetailBloc>().add(QuotationDetailRequested()),
          );
        }
        if (quotation == null) return const AppLoading();
        return PageContent(
          maxWidth: AppSizes.paperWidth,
          header: _toolbar(context, state, quotation),
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                child: RepaintBoundary(key: _paperKey, child: QuotationPaper(quotation: quotation)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar(BuildContext context, QuotationDetailState state, QuotationModel quotation) {
    return PageToolbar(
      actions: [
        OutlinedButton.icon(
          onPressed: () => PdfHelper.printWidget(_paperKey, quotation.quotationNo),
          icon: const Icon(Icons.print_outlined),
          label: Text('invoice.print'.tr),
        ),
        FilledButton.icon(
          onPressed: () => PdfHelper.downloadWidget(_paperKey, quotation.quotationNo),
          icon: const Icon(Icons.download),
          label: Text('invoice.download'.tr),
        ),
        if (!quotation.isCancelled)
          TextButton.icon(
            onPressed: state.cancelStatus == AppStatus.loading ? null : () => _confirmCancel(quotation),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.block),
            label: Text('quotation.cancel_quotation'.tr),
          ),
      ],
      children: [
        TextButton.icon(
          onPressed: () => context.go(AppRoutes.quotations),
          icon: const Icon(Icons.arrow_back),
          label: Text('common.back'.tr),
        ),
      ],
    );
  }
}

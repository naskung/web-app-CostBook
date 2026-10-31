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
import 'package:costbook/features/invoice/bloc/invoice_detail_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/widgets/invoice_paper.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

class InvoiceDetailPage extends StatefulWidget {
  const InvoiceDetailPage({super.key});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  final _paperKey = GlobalKey();

  Future<void> _confirmCancel(InvoiceModel invoice) async {
    final bloc = context.read<InvoiceDetailBloc>();
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'invoice.cancel_title'.trParams({'no': invoice.invoiceNo}),
      message: 'invoice.cancel_message'.tr,
      confirmText: 'invoice.cancel_confirm'.tr,
      icon: Icons.block,
    );
    if (isConfirmed) bloc.add(InvoiceCancelRequested());
  }

  void _onCancelResult(BuildContext context, InvoiceDetailState state) {
    if (state.cancelStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'invoice.cancelled_done'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.cancelErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceDetailBloc, InvoiceDetailState>(
      listenWhen:
          (previous, current) =>
              previous.cancelStatus == AppStatus.loading && current.cancelStatus != AppStatus.loading,
      listener: _onCancelResult,
      builder: (context, state) {
        final invoice = state.invoice;
        if (state.status == AppStatus.failure) {
          return ErrorView(
            message: 'error.${state.errorCode}'.tr,
            retryLabel: 'common.retry'.tr,
            onRetry: () => context.read<InvoiceDetailBloc>().add(InvoiceDetailRequested()),
          );
        }
        if (invoice == null) return const AppLoading();
        return PageContent(
          maxWidth: AppSizes.paperWidth,
          children: [
            _toolbar(context, state, invoice),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                child: RepaintBoundary(key: _paperKey, child: InvoicePaper(invoice: invoice)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar(BuildContext context, InvoiceDetailState state, InvoiceModel invoice) {
    return PageToolbar(
      actions: [
        OutlinedButton.icon(
          onPressed: () => PdfHelper.printWidget(_paperKey, invoice.invoiceNo),
          icon: const Icon(Icons.print_outlined),
          label: Text('invoice.print'.tr),
        ),
        FilledButton.icon(
          onPressed: () => PdfHelper.downloadWidget(_paperKey, invoice.invoiceNo),
          icon: const Icon(Icons.download),
          label: Text('invoice.download'.tr),
        ),
        if (!invoice.isCancelled)
          TextButton.icon(
            onPressed: state.cancelStatus == AppStatus.loading ? null : () => _confirmCancel(invoice),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.block),
            label: Text('invoice.cancel_invoice'.tr),
          ),
      ],
      children: [
        TextButton.icon(
          onPressed: () => context.go(AppRoutes.invoices),
          icon: const Icon(Icons.arrow_back),
          label: Text('common.back'.tr),
        ),
      ],
    );
  }
}

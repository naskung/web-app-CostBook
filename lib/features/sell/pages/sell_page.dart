import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/widgets/invoice_item_row.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_image.dart';
import 'package:costbook/features/sell/widgets/sell_product_tile.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/organisms/app_alert_dialog.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';

part 'sell_page_ext.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _customerController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) => setState(() => _query = query);

  void _onCodeSubmitted(String code) {
    context.read<InvoiceFormBloc>().add(InvoiceCodeScanned(code));
    _searchController.clear();
    setState(() => _query = '');
    _searchFocus.requestFocus();
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final draft = InvoiceDraftModel(
      issueDate: DateUtil.toApiDate(DateTime.now()),
      customerName: _customerController.text.trim(),
    );
    context.read<InvoiceFormBloc>().add(InvoiceFormSubmitted(draft));
  }

  void _startNewSale() {
    _customerController.clear();
    _discountController.clear();
    context.read<InvoiceFormBloc>().add(InvoiceFormReset());
    _searchFocus.requestFocus();
  }

  Future<void> _onSubmitResult(BuildContext context, InvoiceFormState state) async {
    final invoice = state.createdInvoice;
    if (state.submitStatus != AppStatus.success || invoice == null) {
      SnackbarHelper.showError(context, 'error.${state.submitErrorCode}'.trParams(state.submitErrorParams));
      return;
    }
    final router = GoRouter.of(context);
    final wantsDetail = await _showSoldDialog(context, invoice);
    if (wantsDetail) {
      router.go(AppRoutes.invoiceDetailPath(invoice.id));
      return;
    }
    _startNewSale();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InvoiceFormBloc, InvoiceFormState>(
          listenWhen: (previous, current) => previous.scanMissCount != current.scanMissCount,
          listener: (context, state) => SnackbarHelper.showError(context, 'sell.code_not_found'.tr),
        ),
        BlocListener<InvoiceFormBloc, InvoiceFormState>(
          listenWhen:
              (previous, current) =>
                  previous.submitStatus == AppStatus.loading && current.submitStatus != AppStatus.loading,
          listener: _onSubmitResult,
        ),
      ],
      child: BlocBuilder<InvoiceFormBloc, InvoiceFormState>(
        builder: (context, state) {
          final stateView = _stateView(context, state);
          return Form(
            key: _formKey,
            child: PageContent(centerChild: stateView, children: [if (stateView == null) _layout(context, state)]),
          );
        },
      ),
    );
  }

  Widget? _stateView(BuildContext context, InvoiceFormState state) {
    if (state.status == AppStatus.initial || (state.status == AppStatus.loading && state.products.isEmpty)) {
      return const AppLoading();
    }
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<InvoiceFormBloc>().add(InvoiceFormOpened()),
      );
    }
    if (state.products.isEmpty) return EmptyView(message: 'sell.no_products'.tr, icon: Icons.inventory_2_outlined);
    return null;
  }
}

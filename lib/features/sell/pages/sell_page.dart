import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/dialog_helper.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/cash_util.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_image.dart';
import 'package:costbook/features/sell/widgets/payment_dialog.dart';
import 'package:costbook/features/sell/widgets/sell_bill_panel.dart';
import 'package:costbook/features/sell/widgets/sell_product_tile.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/organisms/app_alert_dialog.dart';

part 'sell_page_ext.dart';

// หน้าขายหน้าร้าน (POS): สินค้าด้านซ้าย (เลื่อนได้) + บิลด้านขวาสูงเต็มจอ ปุ่มรับเงินติดอยู่ล่างบิลไม่หลุดจอ
// มือถือ: สินค้าเต็มจอ + แถบยอดรวมติดล่าง กดแล้วบิลเลื่อนขึ้นมา / กดรับเงิน → หน้าต่างรับเงิน + เงินทอน → ขาย
class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  String _query = '';
  String _category = '';
  double _received = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _customerController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) => setState(() => _query = query);

  void _onCategoryChanged(String category) => setState(() => _category = category);

  void _onCodeSubmitted(String code) {
    context.read<InvoiceFormBloc>().add(InvoiceCodeScanned(code));
    _searchController.clear();
    setState(() => _query = '');
    _searchFocus.requestFocus();
  }

  // รับเงิน: หน้าต่างรับเงิน (ได้เงินที่รับมา) → ออกเอกสารขาย / กดยกเลิก = ไม่ขาย
  Future<void> _onPay() async {
    final bloc = context.read<InvoiceFormBloc>();
    final received = await PaymentDialog.show(context, bloc.state.amounts.total);
    if (received == null || !mounted) return;
    _received = received;
    final draft = InvoiceDraftModel(
      issueDate: DateUtil.toApiDate(DateTime.now()),
      customerName: _customerController.text.trim(),
    );
    bloc.add(InvoiceFormSubmitted(draft));
  }

  Future<void> _confirmClear() async {
    final isConfirmed = await DialogHelper.confirm(
      context,
      title: 'sell.clear_title'.tr,
      message: 'sell.clear_message'.tr,
      confirmText: 'sell.clear_bill'.tr,
    );
    if (isConfirmed) _startNewSale();
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
          listenWhen: (previous, current) => previous.outOfStockCount != current.outOfStockCount,
          listener: (context, state) => SnackbarHelper.showError(context, 'invoice.out_of_stock'.tr),
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
          if (stateView != null) return stateView;
          if (ResponsiveHelper.screenType(context) == ScreenType.mobile) return _mobileLayout(context, state);
          return _wideLayout(context, state);
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

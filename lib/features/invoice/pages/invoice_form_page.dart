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
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/widgets/invoice_item_row.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';

part 'invoice_form_page_ext.dart';

class InvoiceFormPage extends StatefulWidget {
  const InvoiceFormPage({super.key});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _branchController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final _discountController = TextEditingController();
  DateTime _issueDate = DateTime.now();
  String? _productToAdd;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateUtil.toDisplayDate(_issueDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _branchController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _issueDate = picked;
      _dateController.text = DateUtil.toDisplayDate(picked);
    });
  }

  void _addProduct(String? productId) {
    if (productId == null) return;
    context.read<InvoiceFormBloc>().add(InvoiceItemAdded(productId));
    setState(() => _productToAdd = null);
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final draft = InvoiceDraftModel(
      issueDate: DateUtil.toApiDate(_issueDate),
      customerName: _nameController.text.trim(),
      customerTaxId: _taxIdController.text.trim(),
      customerBranch: _branchController.text.trim(),
      customerAddress: _addressController.text.trim(),
      note: _noteController.text.trim(),
    );
    context.read<InvoiceFormBloc>().add(InvoiceFormSubmitted(draft));
  }

  void _onSubmitResult(BuildContext context, InvoiceFormState state) {
    final invoice = state.createdInvoice;
    if (state.submitStatus == AppStatus.success && invoice != null) {
      SnackbarHelper.showSuccess(context, 'invoice.created'.trParams({'no': invoice.invoiceNo}));
      context.go(AppRoutes.invoiceDetailPath(invoice.id));
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.submitErrorCode}'.trParams(state.submitErrorParams));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceFormBloc, InvoiceFormState>(
      listenWhen:
          (previous, current) =>
              previous.submitStatus == AppStatus.loading && current.submitStatus != AppStatus.loading,
      listener: _onSubmitResult,
      builder: (context, state) {
        if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
        if (state.status == AppStatus.failure) {
          return ErrorView(
            message: 'error.${state.errorCode}'.tr,
            retryLabel: 'common.retry'.tr,
            onRetry: () => context.read<InvoiceFormBloc>().add(InvoiceFormOpened()),
          );
        }
        return Form(
          key: _formKey,
          child: PageContent(
            maxWidth: AppSizes.contentMaxWidth * 3 / 4,
            children: [
              _backButton(context),
              if (state.company.needsTaxId) _taxIdBanner(context),
              _customerSection(context, state),
              _itemsSection(context, state),
              _totalsSection(context, state),
            ],
          ),
        );
      },
    );
  }
}

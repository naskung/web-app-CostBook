import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/invoice/widgets/document_customer_fields.dart';
import 'package:costbook/features/invoice/widgets/document_totals_summary.dart';
import 'package:costbook/features/invoice/widgets/draft_items_editor.dart';
import 'package:costbook/features/quotation/bloc/quotation_form_bloc.dart';
import 'package:costbook/features/quotation/models/quotation_draft_model.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';

part 'quotation_form_page_ext.dart';

class QuotationFormPage extends StatefulWidget {
  const QuotationFormPage({super.key});

  @override
  State<QuotationFormPage> createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  static const int _validDays = 30;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _branchController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _validUntilController = TextEditingController();
  final _discountController = TextEditingController();
  DateTime _issueDate = DateUtil.dateOnly(DateTime.now());
  late DateTime _validUntil = _issueDate.add(const Duration(days: _validDays));
  String? _productToAdd;

  @override
  void initState() {
    super.initState();
    _issueDateController.text = DateUtil.toDisplayDate(_issueDate);
    _validUntilController.text = DateUtil.toDisplayDate(_validUntil);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _branchController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _issueDateController.dispose();
    _validUntilController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _issueDate = picked;
      _issueDateController.text = DateUtil.toDisplayDate(picked);
      if (_validUntil.isBefore(picked)) _setValidUntil(picked.add(const Duration(days: _validDays)));
    });
  }

  Future<void> _pickValidUntil() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil,
      firstDate: _issueDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _setValidUntil(picked));
  }

  void _setValidUntil(DateTime date) {
    _validUntil = date;
    _validUntilController.text = DateUtil.toDisplayDate(date);
  }

  void _addProduct(String? productId) {
    if (productId == null) return;
    context.read<QuotationFormBloc>().add(QuotationItemAdded(productId));
    setState(() => _productToAdd = null);
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final draft = QuotationDraftModel(
      issueDate: DateUtil.toApiDate(_issueDate),
      validUntil: DateUtil.toApiDate(_validUntil),
      customerName: _nameController.text.trim(),
      customerTaxId: _taxIdController.text.trim(),
      customerBranch: _branchController.text.trim(),
      customerAddress: _addressController.text.trim(),
      note: _noteController.text.trim(),
    );
    context.read<QuotationFormBloc>().add(QuotationFormSubmitted(draft));
  }

  void _onSubmitResult(BuildContext context, QuotationFormState state) {
    final quotation = state.createdQuotation;
    if (state.submitStatus == AppStatus.success && quotation != null) {
      SnackbarHelper.showSuccess(context, 'quotation.created'.trParams({'no': quotation.quotationNo}));
      context.go(AppRoutes.quotationDetailPath(quotation.id));
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.submitErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuotationFormBloc, QuotationFormState>(
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
            onRetry: () => context.read<QuotationFormBloc>().add(QuotationFormOpened()),
          );
        }
        return Form(
          key: _formKey,
          child: PageContent(
            maxWidth: AppSizes.contentMaxWidth * 3 / 4,
            header: _backButton(context),
            children: [_customerSection(context), _itemsSection(context, state), _totalsSection(context, state)],
          ),
        );
      },
    );
  }
}

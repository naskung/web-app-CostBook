import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/transaction/bloc/transaction_bloc.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/organisms/form_dialog.dart';

class TransactionFormDialog extends StatefulWidget {
  const TransactionFormDialog({super.key, required this.transaction});

  final TransactionModel transaction;

  static Future<void> show(BuildContext context, TransactionModel transaction) {
    final bloc = context.read<TransactionBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: TransactionFormDialog(transaction: transaction)),
    );
  }

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(text: _amountText(widget.transaction.amount));
  late final _noteController = TextEditingController(text: widget.transaction.note);
  late final _dateController = TextEditingController();
  late String _type = widget.transaction.type;
  late String _category = widget.transaction.category;
  late DateTime _date = DateUtil.fromApiDate(widget.transaction.date);
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateUtil.toDisplayDate(_date);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _amountText(double amount) {
    if (amount == 0) return '';
    return amount.toString();
  }

  void _onTypeChanged(String type) {
    setState(() {
      _type = type;
      if (!TransactionModel.categoriesOf(type).contains(_category)) _category = '';
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = DateUtil.toDisplayDate(picked);
    });
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isSubmitted = true);
    final transaction = TransactionModel(
      id: widget.transaction.id,
      type: _type,
      category: _category,
      amount: MoneyUtil.parse(_amountController.text),
      date: DateUtil.toApiDate(_date),
      note: _noteController.text.trim(),
    );
    context.read<TransactionBloc>().add(TransactionSaved(transaction));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen:
          (previous, current) => previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final hasError = _isSubmitted && state.saveStatus == AppStatus.failure;
        return FormDialog(
          title: widget.transaction.isNew ? 'transaction.add_title'.tr : 'transaction.edit_title'.tr,
          saveLabel: 'common.save'.tr,
          cancelLabel: 'common.cancel'.tr,
          isSaving: state.saveStatus == AppStatus.loading,
          errorText: hasError ? 'error.${state.saveErrorCode}'.tr : '',
          onSave: _onSave,
          child: _form(),
        );
      },
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: TransactionModel.income, label: Text('transaction.income'.tr)),
              ButtonSegment(value: TransactionModel.expense, label: Text('transaction.expense'.tr)),
            ],
            selected: {_type},
            onSelectionChanged: (selected) => _onTypeChanged(selected.first),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppDropdown<String>(
            label: 'transaction.category'.tr,
            hint: 'transaction.choose_category'.tr,
            value: _category,
            items: {
              for (final category in TransactionModel.categoriesOf(_type))
                category: 'transaction.category.$category'.tr,
            },
            validator: (value) => ValidatorUtil.required(value),
            onChanged: (value) => setState(() => _category = value ?? ''),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: 'common.amount'.tr,
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: ValidatorUtil.positiveNumber,
            suffixText: 'common.baht'.tr,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(
            label: 'common.date'.tr,
            controller: _dateController,
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _pickDate,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          AppTextField(label: 'common.note'.tr, hint: 'transaction.note_hint'.tr, controller: _noteController),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/cash_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/organisms/app_dialog.dart';

// รับเงิน: ใส่เงินที่ลูกค้าให้ (หรือกดปุ่มลัด) → บอกเงินทอน → ยืนยันขาย
// ได้ผลเป็นเงินที่รับมา (null = ยกเลิก) / เว้นว่าง = จ่ายพอดี / เงินทอนไม่ได้บันทึก แค่ช่วยคิด
class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key, required this.total});

  final double total;

  static Future<double?> show(BuildContext context, double total) {
    return showDialog<double>(context: context, builder: (_) => PaymentDialog(total: total));
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _receivedController = TextEditingController();

  double get _received {
    if (_receivedController.text.trim().isEmpty) return widget.total;
    return MoneyUtil.parse(_receivedController.text);
  }

  double get _change => CashUtil.change(_received, widget.total);

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  void _pick(double amount) {
    setState(() => _receivedController.text = MoneyUtil.format(amount));
  }

  void _onConfirm() {
    if (_change < 0) return;
    Navigator.pop(context, _received);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'sell.payment_title'.tr,
      icon: Icons.payments_outlined,
      closeLabel: 'common.cancel'.tr,
      maxWidth: AppSizes.formMaxWidth,
      actions: [
        AppButton(
          text: 'common.cancel'.tr,
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(text: 'sell.confirm_pay'.tr, onPressed: _change < 0 ? null : _onConfirm),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _totalBox(context),
          const SizedBox(height: AppSizes.spaceLarge),
          Text('sell.received'.tr, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSizes.spaceSmall),
          TextField(
            controller: _receivedController,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(hintText: 'sell.received_hint'.tr, suffixText: 'common.baht'.tr),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _onConfirm(),
          ),
          const SizedBox(height: AppSizes.spaceSmall),
          _quickAmounts(),
          const SizedBox(height: AppSizes.spaceLarge),
          _changeLine(context),
        ],
      ),
    );
  }

  Widget _totalBox(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Row(
        children: [
          Expanded(child: Text('sell.payment_total'.tr, style: textTheme.titleMedium)),
          Text(
            MoneyUtil.format(widget.total),
            style: textTheme.headlineSmall?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _quickAmounts() {
    final amounts = CashUtil.quickAmounts(widget.total);
    return Wrap(
      spacing: AppSizes.spaceSmall,
      runSpacing: AppSizes.spaceSmall,
      children: [
        for (var i = 0; i < amounts.length; i++)
          ActionChip(
            label: Text(i == 0 ? 'sell.exact'.tr : MoneyUtil.formatShort(amounts[i])),
            onPressed: () => _pick(amounts[i]),
          ),
      ],
    );
  }

  Widget _changeLine(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final change = _change;
    if (change < 0) {
      return Text(
        'sell.not_enough'.trParams({'amount': MoneyUtil.format(-change)}),
        textAlign: TextAlign.end,
        style: textTheme.titleMedium?.copyWith(color: AppColors.danger),
      );
    }
    return Row(
      children: [
        Expanded(child: Text('sell.change'.tr, style: textTheme.titleMedium)),
        Text(
          MoneyUtil.format(change),
          style: textTheme.headlineSmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

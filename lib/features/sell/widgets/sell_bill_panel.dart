import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/sell/widgets/sell_cart_row.dart';
import 'package:costbook/features/sell/widgets/sell_item_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';

// บิลของหน้าขาย (จอคอม = ด้านขวา / มือถือ = หน้าต่างที่เลื่อนขึ้นมา)
// หัว + รายการ (เลื่อนได้) + ท้ายบิลติดอยู่กับที่: ชื่อลูกค้า / ส่วนลด / ยอดรวม / ปุ่มรับเงิน
// ร้านจด VAT ต้องมีชื่อลูกค้า → ยังไม่ใส่แล้วกดรับเงิน = ขึ้นเตือนที่ช่อง ไม่เรียก onPay
class SellBillPanel extends StatefulWidget {
  const SellBillPanel({
    super.key,
    required this.customerController,
    required this.discountController,
    required this.onPay,
    required this.onClear,
    this.onClose,
  });

  final TextEditingController customerController;
  final TextEditingController discountController;
  final VoidCallback onPay;
  final VoidCallback onClear;
  final VoidCallback? onClose;

  @override
  State<SellBillPanel> createState() => _SellBillPanelState();
}

class _SellBillPanelState extends State<SellBillPanel> {
  bool _isCustomerMissing = false;

  void _onPayPressed(InvoiceFormState state) {
    if (state.needsCustomerName && widget.customerController.text.trim().isEmpty) {
      setState(() => _isCustomerMissing = true);
      return;
    }
    widget.onPay();
  }

  void _onCustomerChanged(String text) {
    if (_isCustomerMissing) setState(() => _isCustomerMissing = false);
  }

  void _editItem(InvoiceDraftItemModel item) {
    final bloc = context.read<InvoiceFormBloc>();
    SellItemDialog.show(
      context,
      item: item,
      onSave:
          (quantity, unitPrice) =>
              bloc.add(InvoiceItemChanged(productId: item.productId, quantity: quantity, unitPrice: unitPrice)),
      onRemove: () => bloc.add(InvoiceItemRemoved(item.productId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceFormBloc, InvoiceFormState>(
      builder: (context, state) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, state),
              const Divider(height: AppSizes.borderWidth),
              Expanded(child: _items(context, state)),
              const Divider(height: AppSizes.borderWidth),
              _footer(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, InvoiceFormState state) {
    final onClose = widget.onClose;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceMedium,
        AppSizes.spaceSmall,
        AppSizes.spaceSmall,
        AppSizes.spaceSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'sell.bill_title'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSmall),
                AppBadge(
                  text: 'sell.bill_count'.trParams({'count': '${state.itemCount}'}),
                  color: AppColors.primaryDark,
                  backgroundColor: AppColors.primarySoft,
                ),
              ],
            ),
          ),
          // ที่ไม่พอ (จอแคบ / ภาษาอังกฤษ) คำว่าล้างบิลหดเป็น ... ไม่ล้นจอ
          if (state.items.isNotEmpty)
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: widget.onClear,
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text('sell.clear_bill'.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          if (onClose != null)
            IconButton(tooltip: 'common.close'.tr, onPressed: onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _items(BuildContext context, InvoiceFormState state) {
    if (state.items.isEmpty) {
      return SingleChildScrollView(
        child: EmptyView(message: 'sell.cart_empty'.tr, icon: Icons.shopping_basket_outlined),
      );
    }
    final bloc = context.read<InvoiceFormBloc>();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMedium),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const Divider(height: AppSizes.borderWidth),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return SellCartRow(
          key: ValueKey(item.productId),
          item: item,
          onEdit: () => _editItem(item),
          onRemove: () => bloc.add(InvoiceItemRemoved(item.productId)),
          onQuantityChanged:
              (quantity) => bloc.add(
                InvoiceItemChanged(productId: item.productId, quantity: quantity, unitPrice: item.unitPrice),
              ),
        );
      },
    );
  }

  Widget _footer(BuildContext context, InvoiceFormState state) {
    final amounts = state.amounts;
    return Container(
      color: AppColors.surfaceMuted,
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.company.needsTaxId) ...[
            NoticeBanner(message: 'invoice.tax_id_missing'.tr),
            const SizedBox(height: AppSizes.spaceSmall),
          ],
          _customerField(state),
          const SizedBox(height: AppSizes.spaceSmall),
          _line(context, 'invoice.items_total'.tr, amounts.itemsTotal),
          _discountLine(context),
          if (state.company.vatRegistered) _line(context, 'invoice.vat'.tr, amounts.vat),
          const Divider(),
          _totalLine(context, amounts.total),
          const SizedBox(height: AppSizes.spaceMedium),
          AppButton(
            text: 'sell.pay'.trParams({'total': MoneyUtil.format(amounts.total)}),
            icon: Icons.payments_outlined,
            isLoading: state.submitStatus == AppStatus.loading,
            onPressed: state.items.isEmpty ? null : () => _onPayPressed(state),
          ),
        ],
      ),
    );
  }

  Widget _customerField(InvoiceFormState state) {
    final hint = state.needsCustomerName ? 'sell.customer_required'.tr : 'sell.customer_optional'.tr;
    return TextField(
      controller: widget.customerController,
      onChanged: _onCustomerChanged,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        prefixIcon: const Icon(Icons.person_outline),
        errorText: _isCustomerMissing ? 'validation.required'.tr : null,
      ),
    );
  }

  Widget _discountLine(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Row(
        children: [
          Expanded(child: Text('invoice.discount'.tr, style: Theme.of(context).textTheme.bodyMedium)),
          SizedBox(
            width: AppSizes.sellDiscountWidth,
            child: TextField(
              controller: widget.discountController,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(hintText: '0.00', isDense: true, suffixText: 'common.baht'.tr),
              onChanged: (text) => context.read<InvoiceFormBloc>().add(InvoiceDiscountChanged(MoneyUtil.parse(text))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, double value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(MoneyUtil.format(value), style: textTheme.titleSmall),
        ],
      ),
    );
  }

  Widget _totalLine(BuildContext context, double total) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text('invoice.grand_total'.tr, style: textTheme.titleMedium)),
        Text(
          MoneyUtil.format(total),
          style: textTheme.headlineSmall?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

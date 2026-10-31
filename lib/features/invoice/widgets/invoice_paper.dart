import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/invoice/models/invoice_item_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';

class InvoicePaper extends StatelessWidget {
  const InvoicePaper({super.key, required this.invoice});

  static const double a4Ratio = 1.4142;

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.paperWidth,
      constraints: const BoxConstraints(minHeight: AppSizes.paperWidth * a4Ratio),
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSizes.paperPadding),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PaperHeader(invoice: invoice),
              const SizedBox(height: AppSizes.spaceLarge),
              _CustomerBox(invoice: invoice),
              const SizedBox(height: AppSizes.spaceLarge),
              _ItemsTable(items: invoice.items),
              _TotalsBox(invoice: invoice),
              const SizedBox(height: AppSizes.spaceXLarge * 2),
              _Signatures(isReceipt: invoice.isReceipt),
            ],
          ),
          if (invoice.isCancelled) const Positioned.fill(child: _CancelledStamp()),
        ],
      ),
    );
  }
}

String _branchText(String branch) {
  if (branch.isEmpty) return '';
  return ' ($branch)';
}

class _PaperHeader extends StatelessWidget {
  const _PaperHeader({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShopLogo(size: AppSizes.paperLogoSize, radius: AppSizes.radiusSmall),
        const SizedBox(width: AppSizes.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invoice.sellerName, style: textTheme.titleLarge),
              if (invoice.sellerAddress.isNotEmpty) Text(invoice.sellerAddress, style: textTheme.bodyMedium),
              if (invoice.sellerTaxId.isNotEmpty)
                Text(
                  'invoice.paper_seller_tax_id'.trParams({'id': invoice.sellerTaxId}) +
                      _branchText(invoice.sellerBranch),
                  style: textTheme.bodyMedium,
                ),
              if (invoice.sellerPhone.isNotEmpty)
                Text('invoice.paper_phone'.trParams({'phone': invoice.sellerPhone}), style: textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.spaceMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              invoice.isReceipt ? 'invoice.paper_title_receipt'.tr : 'invoice.paper_title'.tr,
              style: textTheme.headlineSmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.spaceSmall),
            Text('${'invoice.paper_no'.tr} ${invoice.invoiceNo}', style: textTheme.titleSmall),
            Text(
              '${'invoice.paper_date'.tr} ${DateUtil.toDisplayDate(DateUtil.fromApiDate(invoice.issueDate))}',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomerBox extends StatelessWidget {
  const _CustomerBox({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('invoice.paper_customer'.tr, style: textTheme.bodySmall),
          Text(
            invoice.customerName.isEmpty
                ? 'invoice.walk_in_customer'.tr
                : invoice.customerName + _branchText(invoice.customerBranch),
            style: textTheme.titleSmall,
          ),
          if (invoice.customerAddress.isNotEmpty) Text(invoice.customerAddress, style: textTheme.bodyMedium),
          if (invoice.customerTaxId.isNotEmpty)
            Text('invoice.paper_seller_tax_id'.trParams({'id': invoice.customerTaxId}), style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.items});

  final List<InvoiceItemModel> items;

  static const List<int> _flex = [1, 6, 2, 2, 3, 3];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final header = [
      'invoice.paper_seq'.tr,
      'invoice.paper_item'.tr,
      'common.quantity'.tr,
      'common.unit'.tr,
      'invoice.unit_price'.tr,
      'invoice.line_amount'.tr,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: AppColors.inputFill,
          child: _line([for (final text in header) Text(text, style: textTheme.titleSmall)]),
        ),
        for (var index = 0; index < items.length; index++) ...[
          _line([
            Text('${index + 1}'),
            Text(items[index].name),
            Text('${items[index].quantity}'),
            Text(items[index].unit),
            Text(MoneyUtil.format(items[index].unitPrice)),
            Text(MoneyUtil.format(items[index].amount)),
          ]),
          const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _line(List<Widget> cells) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSmall, vertical: AppSizes.spaceSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: _flex[i],
              child: Align(alignment: i >= 2 ? Alignment.centerRight : Alignment.centerLeft, child: cells[i]),
            ),
        ],
      ),
    );
  }
}

class _TotalsBox extends StatelessWidget {
  const _TotalsBox({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSizes.spaceMedium, right: AppSizes.spaceLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (invoice.pricesIncludeVat) Text('invoice.prices_include_vat'.tr, style: textTheme.bodySmall),
                Text(invoice.note, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        SizedBox(
          width: AppSizes.paperWidth * 0.4,
          child: Column(
            children: [
              const SizedBox(height: AppSizes.spaceSmall),
              _line('invoice.items_total'.tr, invoice.itemsTotal, textTheme.bodyMedium),
              if (invoice.discount > 0) _line('invoice.discount'.tr, invoice.discount, textTheme.bodyMedium),
              if (!invoice.isReceipt) _line('invoice.subtotal'.tr, invoice.subtotal, textTheme.bodyMedium),
              if (!invoice.isReceipt) _line('invoice.vat'.tr, invoice.vat, textTheme.bodyMedium),
              const Divider(),
              _line('invoice.grand_total'.tr, invoice.total, textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _line(String label, double value, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall, horizontal: AppSizes.spaceSmall),
      child: Row(children: [Expanded(child: Text(label, style: style)), Text(MoneyUtil.format(value), style: style)]),
    );
  }
}

class _Signatures extends StatelessWidget {
  const _Signatures({required this.isReceipt});

  final bool isReceipt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _signature(context, 'invoice.paper_receiver'.tr)),
        const SizedBox(width: AppSizes.spaceXLarge * 2),
        Expanded(child: _signature(context, isReceipt ? 'invoice.paper_cashier'.tr : 'invoice.paper_issuer'.tr)),
      ],
    );
  }

  Widget _signature(BuildContext context, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const Divider(color: AppColors.textSecondary),
        Text(label, style: textTheme.bodyMedium),
        Text('${'invoice.paper_date'.tr} ____/____/______', style: textTheme.bodySmall),
      ],
    );
  }
}

class _CancelledStamp extends StatelessWidget {
  const _CancelledStamp();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.rotate(
          angle: -math.pi / 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceLarge, vertical: AppSizes.spaceSmall),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.danger, width: AppSizes.focusBorderWidth * 2),
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Text(
              'invoice.paper_cancelled'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.danger),
            ),
          ),
        ),
      ),
    );
  }
}

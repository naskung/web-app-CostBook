import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/invoice/models/invoice_item_model.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';

class DocumentPaper extends StatelessWidget {
  const DocumentPaper({super.key, required this.children, this.isCancelled = false});

  static const double a4Ratio = 1.4142;

  final List<Widget> children;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.paperWidth,
      constraints: const BoxConstraints(minHeight: AppSizes.paperWidth * a4Ratio),
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSizes.paperPadding),
      child: Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          if (isCancelled) const Positioned.fill(child: _CancelledStamp()),
        ],
      ),
    );
  }
}

String _branchText(String branch) {
  if (branch.isEmpty) return '';
  return ' ($branch)';
}

class PaperHeader extends StatelessWidget {
  const PaperHeader({
    super.key,
    required this.title,
    required this.number,
    required this.infoLines,
    required this.sellerName,
    this.sellerAddress = '',
    this.sellerTaxId = '',
    this.sellerBranch = '',
    this.sellerPhone = '',
  });

  final String title;
  final String number;
  final List<String> infoLines;
  final String sellerName;
  final String sellerAddress;
  final String sellerTaxId;
  final String sellerBranch;
  final String sellerPhone;

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
              Text(sellerName, style: textTheme.titleLarge),
              if (sellerAddress.isNotEmpty) Text(sellerAddress, style: textTheme.bodyMedium),
              if (sellerTaxId.isNotEmpty)
                Text(
                  'invoice.paper_seller_tax_id'.trParams({'id': sellerTaxId}) + _branchText(sellerBranch),
                  style: textTheme.bodyMedium,
                ),
              if (sellerPhone.isNotEmpty)
                Text('invoice.paper_phone'.trParams({'phone': sellerPhone}), style: textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.spaceMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
            const SizedBox(height: AppSizes.spaceSmall),
            Text('${'invoice.paper_no'.tr} $number', style: textTheme.titleSmall),
            for (final line in infoLines) Text(line, style: textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class PaperCustomerBox extends StatelessWidget {
  const PaperCustomerBox({super.key, required this.name, this.address = '', this.taxId = '', this.branch = ''});

  final String name;
  final String address;
  final String taxId;
  final String branch;

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
          Text(name.isEmpty ? 'invoice.walk_in_customer'.tr : name + _branchText(branch), style: textTheme.titleSmall),
          if (address.isNotEmpty) Text(address, style: textTheme.bodyMedium),
          if (taxId.isNotEmpty)
            Text('invoice.paper_seller_tax_id'.trParams({'id': taxId}), style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class PaperItemsTable extends StatelessWidget {
  const PaperItemsTable({super.key, required this.items});

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

class PaperTotals extends StatelessWidget {
  const PaperTotals({
    super.key,
    required this.amounts,
    required this.showVat,
    this.pricesIncludeVat = false,
    this.note = '',
  });

  final DocumentAmounts amounts;
  final bool showVat;
  final bool pricesIncludeVat;
  final String note;

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
                if (pricesIncludeVat) Text('invoice.prices_include_vat'.tr, style: textTheme.bodySmall),
                Text(note, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        SizedBox(
          width: AppSizes.paperWidth * 0.4,
          child: Column(
            children: [
              const SizedBox(height: AppSizes.spaceSmall),
              _line('invoice.items_total'.tr, amounts.itemsTotal, textTheme.bodyMedium),
              if (amounts.discount > 0) _line('invoice.discount'.tr, amounts.discount, textTheme.bodyMedium),
              if (showVat) _line('invoice.subtotal'.tr, amounts.subtotal, textTheme.bodyMedium),
              if (showVat) _line('invoice.vat'.tr, amounts.vat, textTheme.bodyMedium),
              const Divider(),
              _line('invoice.grand_total'.tr, amounts.total, textTheme.titleMedium),
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

class PaperSignatures extends StatelessWidget {
  const PaperSignatures({super.key, required this.leftLabel, required this.rightLabel});

  final String leftLabel;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _signature(context, leftLabel)),
        const SizedBox(width: AppSizes.spaceXLarge * 2),
        Expanded(child: _signature(context, rightLabel)),
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

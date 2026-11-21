import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/invoice/widgets/document_paper.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';

class QuotationPaper extends StatelessWidget {
  const QuotationPaper({super.key, required this.quotation});

  final QuotationModel quotation;

  @override
  Widget build(BuildContext context) {
    return DocumentPaper(
      isCancelled: quotation.isCancelled,
      children: [
        PaperHeader(
          title: 'quotation.paper_title'.tr,
          number: quotation.quotationNo,
          infoLines: [
            '${'invoice.paper_date'.tr} ${_displayDate(quotation.issueDate)}',
            '${'quotation.valid_until'.tr} ${_displayDate(quotation.validUntil)}',
          ],
          sellerName: quotation.sellerName,
          sellerAddress: quotation.sellerAddress,
          sellerTaxId: quotation.sellerTaxId,
          sellerBranch: quotation.sellerBranch,
          sellerPhone: quotation.sellerPhone,
        ),
        const SizedBox(height: AppSizes.spaceLarge),
        PaperCustomerBox(
          name: quotation.customerName,
          address: quotation.customerAddress,
          taxId: quotation.customerTaxId,
          branch: quotation.customerBranch,
        ),
        const SizedBox(height: AppSizes.spaceLarge),
        PaperItemsTable(items: quotation.items),
        PaperTotals(
          amounts: DocumentAmounts(
            itemsTotal: quotation.itemsTotal,
            discount: quotation.discount,
            subtotal: quotation.subtotal,
            vat: quotation.vat,
            total: quotation.total,
          ),
          showVat: quotation.withVat,
          pricesIncludeVat: quotation.pricesIncludeVat,
          note: quotation.note,
        ),
        const SizedBox(height: AppSizes.spaceXLarge * 2),
        PaperSignatures(leftLabel: 'quotation.paper_approver'.tr, rightLabel: 'quotation.paper_proposer'.tr),
      ],
    );
  }

  String _displayDate(String apiDate) {
    return DateUtil.toDisplayDate(DateUtil.fromApiDate(apiDate));
  }
}

import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/widgets/document_paper.dart';

class InvoicePaper extends StatelessWidget {
  const InvoicePaper({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    return DocumentPaper(
      isCancelled: invoice.isCancelled,
      children: [
        PaperHeader(
          title: invoice.isReceipt ? 'invoice.paper_title_receipt'.tr : 'invoice.paper_title'.tr,
          number: invoice.invoiceNo,
          infoLines: ['${'invoice.paper_date'.tr} ${DateUtil.toDisplayDate(DateUtil.fromApiDate(invoice.issueDate))}'],
          sellerName: invoice.sellerName,
          sellerAddress: invoice.sellerAddress,
          sellerTaxId: invoice.sellerTaxId,
          sellerBranch: invoice.sellerBranch,
          sellerPhone: invoice.sellerPhone,
        ),
        const SizedBox(height: AppSizes.spaceLarge),
        PaperCustomerBox(
          name: invoice.customerName,
          address: invoice.customerAddress,
          taxId: invoice.customerTaxId,
          branch: invoice.customerBranch,
        ),
        const SizedBox(height: AppSizes.spaceLarge),
        PaperItemsTable(items: invoice.items),
        PaperTotals(
          amounts: DocumentAmounts(
            itemsTotal: invoice.itemsTotal,
            discount: invoice.discount,
            subtotal: invoice.subtotal,
            vat: invoice.vat,
            total: invoice.total,
          ),
          showVat: !invoice.isReceipt,
          pricesIncludeVat: invoice.pricesIncludeVat,
          note: invoice.note,
        ),
        const SizedBox(height: AppSizes.spaceXLarge * 2),
        PaperSignatures(
          leftLabel: 'invoice.paper_receiver'.tr,
          rightLabel: invoice.isReceipt ? 'invoice.paper_cashier'.tr : 'invoice.paper_issuer'.tr,
        ),
      ],
    );
  }
}

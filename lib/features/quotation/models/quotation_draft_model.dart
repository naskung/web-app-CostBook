import 'package:equatable/equatable.dart';

import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';

class QuotationDraftModel extends Equatable {
  const QuotationDraftModel({
    required this.issueDate,
    required this.validUntil,
    this.customerName = '',
    this.customerAddress = '',
    this.customerTaxId = '',
    this.customerBranch = '',
    this.note = '',
    this.discount = 0,
    this.items = const [],
  });

  final String issueDate;
  final String validUntil;
  final String customerName;
  final String customerAddress;
  final String customerTaxId;
  final String customerBranch;
  final String note;
  final double discount;
  final List<InvoiceDraftItemModel> items;

  double get itemsTotal => MoneyUtil.sum(items.map((item) => item.amount));

  DocumentAmounts amounts({required bool vatRegistered, required bool pricesIncludeVat}) {
    return TaxUtil.documentAmounts(
      itemsTotal: itemsTotal,
      discount: discount,
      vatRegistered: vatRegistered,
      pricesIncludeVat: pricesIncludeVat,
    );
  }

  QuotationDraftModel copyWith({List<InvoiceDraftItemModel>? items, double? discount}) {
    return QuotationDraftModel(
      issueDate: issueDate,
      validUntil: validUntil,
      customerName: customerName,
      customerAddress: customerAddress,
      customerTaxId: customerTaxId,
      customerBranch: customerBranch,
      note: note,
      discount: discount ?? this.discount,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue_date': issueDate,
      'valid_until': validUntil,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'customer_tax_id': customerTaxId,
      'customer_branch': customerBranch,
      'note': note,
      'discount': discount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    issueDate,
    validUntil,
    customerName,
    customerAddress,
    customerTaxId,
    customerBranch,
    note,
    discount,
    items,
  ];
}

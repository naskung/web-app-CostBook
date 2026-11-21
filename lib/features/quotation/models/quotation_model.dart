import 'package:equatable/equatable.dart';

import 'package:costbook/features/invoice/models/invoice_item_model.dart';

class QuotationModel extends Equatable {
  const QuotationModel({
    required this.id,
    required this.quotationNo,
    required this.issueDate,
    required this.validUntil,
    required this.status,
    this.sellerName = '',
    this.sellerAddress = '',
    this.sellerTaxId = '',
    this.sellerBranch = '',
    this.sellerPhone = '',
    required this.customerName,
    this.customerAddress = '',
    this.customerTaxId = '',
    this.customerBranch = '',
    this.note = '',
    this.withVat = false,
    this.pricesIncludeVat = false,
    this.itemsTotal = 0,
    this.discount = 0,
    this.subtotal = 0,
    this.vat = 0,
    required this.total,
    this.items = const [],
  });

  static const String issued = 'issued';
  static const String cancelled = 'cancelled';

  final String id;
  final String quotationNo;
  final String issueDate;
  final String validUntil;
  final String status;
  final String sellerName;
  final String sellerAddress;
  final String sellerTaxId;
  final String sellerBranch;
  final String sellerPhone;
  final String customerName;
  final String customerAddress;
  final String customerTaxId;
  final String customerBranch;
  final String note;
  final bool withVat;
  final bool pricesIncludeVat;
  final double itemsTotal;
  final double discount;
  final double subtotal;
  final double vat;
  final double total;
  final List<InvoiceItemModel> items;

  bool get isCancelled => status == cancelled;

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    return QuotationModel(
      id: json['id'] as String? ?? '',
      quotationNo: json['quotation_no'] as String? ?? '',
      issueDate: json['issue_date'] as String? ?? '',
      validUntil: json['valid_until'] as String? ?? '',
      status: json['status'] as String? ?? issued,
      sellerName: json['seller_name'] as String? ?? '',
      sellerAddress: json['seller_address'] as String? ?? '',
      sellerTaxId: json['seller_tax_id'] as String? ?? '',
      sellerBranch: json['seller_branch'] as String? ?? '',
      sellerPhone: json['seller_phone'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerAddress: json['customer_address'] as String? ?? '',
      customerTaxId: json['customer_tax_id'] as String? ?? '',
      customerBranch: json['customer_branch'] as String? ?? '',
      note: json['note'] as String? ?? '',
      withVat: json['with_vat'] as bool? ?? false,
      pricesIncludeVat: json['prices_include_vat'] as bool? ?? false,
      itemsTotal: (json['items_total'] as num? ?? 0).toDouble(),
      discount: (json['discount'] as num? ?? 0).toDouble(),
      subtotal: (json['subtotal'] as num? ?? 0).toDouble(),
      vat: (json['vat'] as num? ?? 0).toDouble(),
      total: (json['total'] as num? ?? 0).toDouble(),
      items: items.map((item) => InvoiceItemModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_no': quotationNo,
      'issue_date': issueDate,
      'valid_until': validUntil,
      'status': status,
      'seller_name': sellerName,
      'seller_address': sellerAddress,
      'seller_tax_id': sellerTaxId,
      'seller_branch': sellerBranch,
      'seller_phone': sellerPhone,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'customer_tax_id': customerTaxId,
      'customer_branch': customerBranch,
      'note': note,
      'with_vat': withVat,
      'prices_include_vat': pricesIncludeVat,
      'items_total': itemsTotal,
      'discount': discount,
      'subtotal': subtotal,
      'vat': vat,
      'total': total,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    quotationNo,
    issueDate,
    validUntil,
    status,
    sellerName,
    sellerAddress,
    sellerTaxId,
    sellerBranch,
    sellerPhone,
    customerName,
    customerAddress,
    customerTaxId,
    customerBranch,
    note,
    withVat,
    pricesIncludeVat,
    itemsTotal,
    discount,
    subtotal,
    vat,
    total,
    items,
  ];
}

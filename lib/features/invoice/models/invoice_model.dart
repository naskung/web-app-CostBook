import 'package:equatable/equatable.dart';

import 'package:costbook/core/constants/delivery_status.dart';
import 'package:costbook/features/invoice/models/invoice_item_model.dart';

class InvoiceModel extends Equatable {
  const InvoiceModel({
    required this.id,
    this.docType = taxInvoice,
    required this.invoiceNo,
    required this.issueDate,
    required this.status,
    this.deliveryStatus = DeliveryStatus.received,
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
    this.pricesIncludeVat = false,
    this.itemsTotal = 0,
    this.discount = 0,
    required this.subtotal,
    required this.vat,
    required this.total,
    this.items = const [],
  });

  static const String issued = 'issued';
  static const String cancelled = 'cancelled';
  static const String taxInvoice = 'tax_invoice';
  static const String receipt = 'receipt';

  final String id;
  final String docType;
  final String invoiceNo;
  final String issueDate;
  final String status;
  final DeliveryStatus deliveryStatus;
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
  final bool pricesIncludeVat;
  final double itemsTotal;
  final double discount;
  final double subtotal;
  final double vat;
  final double total;
  final List<InvoiceItemModel> items;

  bool get isCancelled => status == cancelled;

  bool get isReceipt => docType == receipt;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    return InvoiceModel(
      id: json['id'] as String? ?? '',
      docType: json['doc_type'] as String? ?? taxInvoice,
      invoiceNo: json['invoice_no'] as String? ?? '',
      issueDate: json['issue_date'] as String? ?? '',
      status: json['status'] as String? ?? issued,
      deliveryStatus: DeliveryStatus.fromName(json['delivery_status'] as String?),
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
      'doc_type': docType,
      'invoice_no': invoiceNo,
      'issue_date': issueDate,
      'status': status,
      'delivery_status': deliveryStatus.name,
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
    docType,
    invoiceNo,
    issueDate,
    status,
    deliveryStatus,
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
    pricesIncludeVat,
    itemsTotal,
    discount,
    subtotal,
    vat,
    total,
    items,
  ];
}

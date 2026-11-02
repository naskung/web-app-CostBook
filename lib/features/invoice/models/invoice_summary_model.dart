import 'package:equatable/equatable.dart';

import 'package:costbook/core/constants/delivery_status.dart';

class InvoiceSummaryModel extends Equatable {
  const InvoiceSummaryModel({
    required this.id,
    this.docType = 'tax_invoice',
    required this.invoiceNo,
    required this.issueDate,
    required this.status,
    this.deliveryStatus = DeliveryStatus.received,
    required this.customerName,
    required this.total,
  });

  final String id;
  final String docType;
  final String invoiceNo;
  final String issueDate;
  final String status;
  final DeliveryStatus deliveryStatus;
  final String customerName;
  final double total;

  bool get isCancelled => status == 'cancelled';

  bool get isReceipt => docType == 'receipt';

  factory InvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSummaryModel(
      id: json['id'] as String? ?? '',
      docType: json['doc_type'] as String? ?? 'tax_invoice',
      invoiceNo: json['invoice_no'] as String? ?? '',
      issueDate: json['issue_date'] as String? ?? '',
      status: json['status'] as String? ?? 'issued',
      deliveryStatus: DeliveryStatus.fromName(json['delivery_status'] as String?),
      customerName: json['customer_name'] as String? ?? '',
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }

  InvoiceSummaryModel copyWith({DeliveryStatus? deliveryStatus}) {
    return InvoiceSummaryModel(
      id: id,
      docType: docType,
      invoiceNo: invoiceNo,
      issueDate: issueDate,
      status: status,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      customerName: customerName,
      total: total,
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
      'customer_name': customerName,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [id, docType, invoiceNo, issueDate, status, deliveryStatus, customerName, total];
}

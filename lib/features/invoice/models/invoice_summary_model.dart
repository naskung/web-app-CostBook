import 'package:equatable/equatable.dart';

class InvoiceSummaryModel extends Equatable {
  const InvoiceSummaryModel({
    required this.id,
    required this.invoiceNo,
    required this.issueDate,
    required this.status,
    required this.customerName,
    required this.total,
  });

  final String id;
  final String invoiceNo;
  final String issueDate;
  final String status;
  final String customerName;
  final double total;

  bool get isCancelled => status == 'cancelled';

  factory InvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSummaryModel(
      id: json['id'] as String? ?? '',
      invoiceNo: json['invoice_no'] as String? ?? '',
      issueDate: json['issue_date'] as String? ?? '',
      status: json['status'] as String? ?? 'issued',
      customerName: json['customer_name'] as String? ?? '',
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'issue_date': issueDate,
      'status': status,
      'customer_name': customerName,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [id, invoiceNo, issueDate, status, customerName, total];
}

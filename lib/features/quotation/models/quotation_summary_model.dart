import 'package:equatable/equatable.dart';

class QuotationSummaryModel extends Equatable {
  const QuotationSummaryModel({
    required this.id,
    required this.quotationNo,
    required this.issueDate,
    required this.validUntil,
    required this.status,
    required this.customerName,
    required this.total,
  });

  final String id;
  final String quotationNo;
  final String issueDate;
  final String validUntil;
  final String status;
  final String customerName;
  final double total;

  bool get isCancelled => status == 'cancelled';

  factory QuotationSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuotationSummaryModel(
      id: json['id'] as String? ?? '',
      quotationNo: json['quotation_no'] as String? ?? '',
      issueDate: json['issue_date'] as String? ?? '',
      validUntil: json['valid_until'] as String? ?? '',
      status: json['status'] as String? ?? 'issued',
      customerName: json['customer_name'] as String? ?? '',
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_no': quotationNo,
      'issue_date': issueDate,
      'valid_until': validUntil,
      'status': status,
      'customer_name': customerName,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [id, quotationNo, issueDate, validUntil, status, customerName, total];
}

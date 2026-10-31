import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  const TransactionModel({
    this.id = '',
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
    this.invoiceId = '',
    this.invoiceNo = '',
  });

  static const String income = 'income';
  static const String expense = 'expense';
  static const List<String> incomeCategories = ['sales', 'other_income'];
  static const List<String> expenseCategories = [
    'material',
    'labor',
    'rent',
    'utilities',
    'shipping',
    'marketing',
    'other_expense',
  ];

  final String id;
  final String type;
  final String category;
  final double amount;
  final String date;
  final String note;
  final String invoiceId;
  final String invoiceNo;

  bool get isNew => id.isEmpty;

  bool get isIncome => type == income;

  bool get isFromInvoice => invoiceId.isNotEmpty;

  static List<String> categoriesOf(String type) {
    if (type == income) return incomeCategories;
    return expenseCategories;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? expense,
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      date: json['date'] as String? ?? '',
      note: json['note'] as String? ?? '',
      invoiceId: json['invoice_id'] as String? ?? '',
      invoiceNo: json['invoice_no'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'category': category, 'amount': amount, 'date': date, 'note': note};
  }

  @override
  List<Object?> get props => [id, type, category, amount, date, note, invoiceId, invoiceNo];
}

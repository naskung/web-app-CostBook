import 'package:equatable/equatable.dart';

class TransactionSummaryModel extends Equatable {
  const TransactionSummaryModel({this.income = 0, this.expense = 0, this.profit = 0});

  final double income;
  final double expense;
  final double profit;

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    return TransactionSummaryModel(
      income: (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] as num? ?? 0).toDouble(),
      profit: (json['profit'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'income': income, 'expense': expense, 'profit': profit};
  }

  @override
  List<Object?> get props => [income, expense, profit];
}

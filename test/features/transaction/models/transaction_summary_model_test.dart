import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/transaction/models/transaction_summary_model.dart';

void main() {
  group('TransactionSummaryModel', () {
    test('fromJson อ่านรายได้ ต้นทุน รายจ่าย กำไรสุทธิ ได้ถูกต้อง', () {
      final json = {
        'month': '2026-11',
        'income': 1370,
        'expense': 1600,
        'sales': 1000,
        'other_income': 300,
        'revenue': 1300,
        'cost_of_sales': 600,
        'gross_profit': 400,
        'material_expense': 1250,
        'operating_expense': 350,
        'profit': 350,
      };
      expect(
        TransactionSummaryModel.fromJson(json),
        const TransactionSummaryModel(
          income: 1370,
          expense: 1600,
          sales: 1000,
          otherIncome: 300,
          revenue: 1300,
          costOfSales: 600,
          grossProfit: 400,
          materialExpense: 1250,
          operatingExpense: 350,
          profit: 350,
        ),
      );
    });

    test('ขาดทุน กำไรสุทธิเป็นค่าติดลบ', () {
      final summary = TransactionSummaryModel.fromJson({'revenue': 100, 'cost_of_sales': 80, 'profit': -50.5});
      expect(summary.profit, -50.5);
    });

    test('API เก่าที่ไม่มี field ใหม่ ได้ 0 ไม่พัง', () {
      final summary = TransactionSummaryModel.fromJson({'income': 48.15, 'expense': 300});
      expect([summary.income, summary.revenue, summary.costOfSales], [48.15, 0, 0]);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      const summary = TransactionSummaryModel(revenue: 1000, costOfSales: 600, operatingExpense: 100, profit: 300);
      expect(TransactionSummaryModel.fromJson(summary.toJson()), summary);
    });
  });
}

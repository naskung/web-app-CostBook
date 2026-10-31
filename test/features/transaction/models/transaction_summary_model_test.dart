import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/transaction/models/transaction_summary_model.dart';

void main() {
  group('TransactionSummaryModel', () {
    test('fromJson อ่านยอดสรุปได้ถูกต้อง (ขาดทุนเป็นค่าติดลบ)', () {
      final json = {'month': '2026-10', 'income': 48.15, 'expense': 300, 'profit': -251.85};
      expect(
        TransactionSummaryModel.fromJson(json),
        const TransactionSummaryModel(income: 48.15, expense: 300, profit: -251.85),
      );
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      const summary = TransactionSummaryModel(income: 1000, expense: 400, profit: 600);
      expect(TransactionSummaryModel.fromJson(summary.toJson()), summary);
    });
  });
}

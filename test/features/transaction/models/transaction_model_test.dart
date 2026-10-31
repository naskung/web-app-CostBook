import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/transaction/models/transaction_model.dart';

void main() {
  const fromInvoice = TransactionModel(
    id: 't1',
    type: 'income',
    category: 'sales',
    amount: 107,
    date: '2026-10-31',
    note: 'INV-2026-0001',
    invoiceId: 'i1',
    invoiceNo: 'INV-2026-0001',
  );

  group('TransactionModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': 't1',
        'type': 'income',
        'category': 'sales',
        'amount': 107,
        'date': '2026-10-31',
        'note': 'INV-2026-0001',
        'invoice_id': 'i1',
        'invoice_no': 'INV-2026-0001',
      };
      expect(TransactionModel.fromJson(json), fromInvoice);
    });

    test('toJson ส่งเฉพาะ field ที่ API รับ', () {
      expect(fromInvoice.toJson(), {
        'type': 'income',
        'category': 'sales',
        'amount': 107.0,
        'date': '2026-10-31',
        'note': 'INV-2026-0001',
      });
    });

    test('isIncome / isFromInvoice / isNew', () {
      expect(fromInvoice.isIncome, true);
      expect(fromInvoice.isFromInvoice, true);
      expect(fromInvoice.isNew, false);
      const expense = TransactionModel(type: 'expense', category: 'rent', amount: 5000, date: '2026-10-01');
      expect(expense.isIncome, false);
      expect(expense.isFromInvoice, false);
      expect(expense.isNew, true);
    });

    test('หมวดของรายรับ / รายจ่าย ไม่ปนกัน', () {
      expect(TransactionModel.categoriesOf('income'), contains('sales'));
      expect(TransactionModel.categoriesOf('expense'), isNot(contains('sales')));
    });
  });
}

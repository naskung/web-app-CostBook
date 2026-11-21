import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/quotation/models/quotation_summary_model.dart';

void main() {
  const summary = QuotationSummaryModel(
    id: 'q1',
    quotationNo: 'QT-2026-0001',
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    status: 'issued',
    customerName: 'ลูกค้า',
    total: 107,
  );

  group('QuotationSummaryModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': 'q1',
        'quotation_no': 'QT-2026-0001',
        'issue_date': '2026-11-21',
        'valid_until': '2026-12-21',
        'status': 'issued',
        'customer_name': 'ลูกค้า',
        'total': 107,
      };
      expect(QuotationSummaryModel.fromJson(json), summary);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(QuotationSummaryModel.fromJson(summary.toJson()), summary);
    });

    test('isCancelled เป็น true เมื่อ status = cancelled', () {
      expect(summary.isCancelled, false);
      expect(QuotationSummaryModel.fromJson({...summary.toJson(), 'status': 'cancelled'}).isCancelled, true);
    });
  });
}

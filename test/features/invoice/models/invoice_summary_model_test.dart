import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/models/invoice_summary_model.dart';

void main() {
  group('InvoiceSummaryModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง และ toJson กลับมาได้ค่าเดิม', () {
      final json = {
        'id': 'i1',
        'invoice_no': 'INV-2026-0002',
        'issue_date': '2026-10-31',
        'status': 'issued',
        'customer_name': 'ลูกค้า',
        'total': 48.15,
      };
      final summary = InvoiceSummaryModel.fromJson(json);
      expect(summary.invoiceNo, 'INV-2026-0002');
      expect(summary.total, 48.15);
      expect(InvoiceSummaryModel.fromJson(summary.toJson()), summary);
    });

    test('isCancelled เป็น true เมื่อ status = cancelled', () {
      final cancelled = InvoiceSummaryModel.fromJson({'status': 'cancelled'});
      expect(cancelled.isCancelled, true);
    });
  });
}

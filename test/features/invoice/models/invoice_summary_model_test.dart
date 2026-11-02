import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/delivery_status.dart';
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

    test('อ่านสถานะการส่งสินค้า / ไม่มีมา (API เก่า) = received', () {
      expect(InvoiceSummaryModel.fromJson({'delivery_status': 'pending'}).deliveryStatus, DeliveryStatus.pending);
      expect(InvoiceSummaryModel.fromJson({}).deliveryStatus, DeliveryStatus.received);
    });

    test('copyWith เปลี่ยนแค่สถานะการส่ง ค่าอื่นเหมือนเดิม', () {
      final summary = InvoiceSummaryModel.fromJson({'id': 'i1', 'invoice_no': 'RC-2026-0001', 'total': 99});
      final shipped = summary.copyWith(deliveryStatus: DeliveryStatus.shipped);
      expect(shipped.deliveryStatus, DeliveryStatus.shipped);
      expect([shipped.id, shipped.invoiceNo, shipped.total], ['i1', 'RC-2026-0001', 99]);
    });

    test('isCancelled เป็น true เมื่อ status = cancelled', () {
      final cancelled = InvoiceSummaryModel.fromJson({'status': 'cancelled'});
      expect(cancelled.isCancelled, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/models/invoice_draft_model.dart';

void main() {
  const coffee = InvoiceDraftItemModel(productId: 'p1', name: 'กาแฟเย็น', stock: 5, quantity: 3, unitPrice: 45);
  const tea = InvoiceDraftItemModel(productId: 'p2', name: 'ชาไทย', stock: 0, quantity: 1, unitPrice: 42.5);
  const draft = InvoiceDraftModel(issueDate: '2026-10-31', customerName: 'ลูกค้า', items: [coffee, tea]);

  group('InvoiceDraftModel', () {
    test('ยอดบรรทัด 3 x 45 = 135', () {
      expect(coffee.amount, 135);
    });

    test('ยอดรวม 177.5 VAT 12.43 รวมทั้งสิ้น 189.93 (VAT คิดจากยอดรวมทั้งใบ)', () {
      expect(draft.subtotal, 177.5);
      expect(draft.vat, 12.43);
      expect(draft.total, 189.93);
    });

    test('ไม่มีสินค้า ยอดทุกช่องเป็น 0', () {
      const empty = InvoiceDraftModel(issueDate: '2026-10-31', customerName: 'ลูกค้า');
      expect([empty.subtotal, empty.vat, empty.total], [0, 0, 0]);
    });

    test('isOverStock เมื่อจำนวนเกินคงเหลือ', () {
      expect(coffee.isOverStock, false);
      expect(tea.isOverStock, true);
    });

    test('toJson ส่งข้อมูลลูกค้าและรายการแบบที่ API รับ', () {
      final json = draft.toJson();
      expect(json['customer_name'], 'ลูกค้า');
      expect(json['items'], [
        {'product_id': 'p1', 'quantity': 3, 'unit_price': 45.0},
        {'product_id': 'p2', 'quantity': 1, 'unit_price': 42.5},
      ]);
    });
  });
}

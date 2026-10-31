import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/models/invoice_item_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';

void main() {
  const invoice = InvoiceModel(
    id: 'i1',
    invoiceNo: 'INV-2026-0001',
    issueDate: '2026-10-31',
    status: 'cancelled',
    sellerName: 'ร้านตัวอย่าง',
    sellerTaxId: '0105555555555',
    sellerBranch: 'สำนักงานใหญ่',
    customerName: 'บริษัท ลูกค้า จำกัด',
    subtotal: 177.5,
    vat: 12.43,
    total: 189.93,
    items: [
      InvoiceItemModel(
        id: 'l1',
        productId: 'p1',
        name: 'กาแฟเย็น',
        unit: 'แก้ว',
        quantity: 3,
        unitPrice: 45,
        amount: 135,
      ),
    ],
  );

  group('InvoiceModel', () {
    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม (รวมรายการสินค้า)', () {
      expect(InvoiceModel.fromJson(invoice.toJson()), invoice);
    });

    test('fromJson อ่านรายการสินค้าในใบได้', () {
      final parsed = InvoiceModel.fromJson(invoice.toJson());
      expect(parsed.items.single.name, 'กาแฟเย็น');
      expect(parsed.items.single.amount, 135);
    });

    test('isCancelled เป็น true เมื่อ status = cancelled', () {
      expect(invoice.isCancelled, true);
    });

    test('ไม่มี field ไหนเลย ไม่ error', () {
      final empty = InvoiceModel.fromJson({});
      expect(empty.items, isEmpty);
      expect(empty.isCancelled, false);
    });
  });
}

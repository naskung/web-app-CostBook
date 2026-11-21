import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/models/invoice_item_model.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';

void main() {
  const quotation = QuotationModel(
    id: 'q1',
    quotationNo: 'QT-2026-0001',
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    status: 'issued',
    sellerName: 'ร้านตัวอย่าง',
    customerName: 'บริษัท ลูกค้า จำกัด',
    withVat: true,
    itemsTotal: 100,
    subtotal: 100,
    vat: 7,
    total: 107,
    items: [InvoiceItemModel(id: 'l1', productId: 'p1', name: 'กาแฟเย็น', quantity: 2, unitPrice: 50, amount: 100)],
  );

  group('QuotationModel', () {
    test('fromJson อ่านเลขที่ วันยืนราคา คิด VAT และรายการสินค้าได้', () {
      final json = {
        'id': 'q1',
        'quotation_no': 'QT-2026-0001',
        'issue_date': '2026-11-21',
        'valid_until': '2026-12-21',
        'status': 'issued',
        'seller_name': 'ร้านตัวอย่าง',
        'customer_name': 'บริษัท ลูกค้า จำกัด',
        'with_vat': true,
        'items_total': 100,
        'subtotal': 100,
        'vat': 7,
        'total': 107,
        'items': [
          {'id': 'l1', 'product_id': 'p1', 'name': 'กาแฟเย็น', 'quantity': 2, 'unit_price': 50, 'amount': 100},
        ],
      };
      expect(QuotationModel.fromJson(json), quotation);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(QuotationModel.fromJson(quotation.toJson()), quotation);
    });

    test('ไม่มีบาง field ได้ค่าเริ่มต้น (ไม่ error)', () {
      final parsed = QuotationModel.fromJson({'id': 'q1'});
      expect([parsed.status, parsed.withVat, parsed.total, parsed.items], ['issued', false, 0, []]);
    });

    test('isCancelled เป็น true เมื่อ status = cancelled', () {
      expect(quotation.isCancelled, false);
      expect(QuotationModel.fromJson({...quotation.toJson(), 'status': 'cancelled'}).isCancelled, true);
    });
  });
}

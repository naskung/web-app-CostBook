import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/quotation/models/quotation_draft_model.dart';

void main() {
  const coffee = InvoiceDraftItemModel(productId: 'p1', name: 'กาแฟเย็น', quantity: 2, unitPrice: 50);
  const draft = QuotationDraftModel(
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    customerName: 'ลูกค้า',
    items: [coffee],
  );

  group('QuotationDraftModel', () {
    test('ร้านจด VAT ราคาไม่รวม VAT: 100 + VAT 7 = 107', () {
      final amounts = draft.amounts(vatRegistered: true, pricesIncludeVat: false);
      expect([amounts.itemsTotal, amounts.subtotal, amounts.vat, amounts.total], [100, 100, 7, 107]);
    });

    test('ร้านไม่จด VAT ลด 10: ไม่มี VAT รวม 90', () {
      final amounts = draft.copyWith(discount: 10).amounts(vatRegistered: false, pricesIncludeVat: false);
      expect([amounts.vat, amounts.total], [0, 90]);
    });

    test('toJson ส่งวันยืนราคา ลูกค้า ส่วนลด และรายการแบบที่ API รับ', () {
      final json = draft.copyWith(discount: 5).toJson();
      expect(json['issue_date'], '2026-11-21');
      expect(json['valid_until'], '2026-12-21');
      expect(json['customer_name'], 'ลูกค้า');
      expect(json['discount'], 5);
      expect(json['items'], [
        {'product_id': 'p1', 'quantity': 2, 'unit_price': 50.0},
      ]);
    });

    test('copyWith เปลี่ยนแค่รายการ / ส่วนลด ข้อมูลอื่นเหมือนเดิม', () {
      final changed = draft.copyWith(items: const [], discount: 3);
      expect(
        [changed.validUntil, changed.customerName, changed.items, changed.discount],
        ['2026-12-21', 'ลูกค้า', [], 3],
      );
    });
  });
}

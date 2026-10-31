import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/product/models/product_model.dart';

void main() {
  const coffee = InvoiceDraftItemModel(productId: 'p1', name: 'กาแฟเย็น', stock: 5, quantity: 3, unitPrice: 45);
  const tea = InvoiceDraftItemModel(productId: 'p2', name: 'ชาไทย', stock: 0, quantity: 1, unitPrice: 42.5);
  const draft = InvoiceDraftModel(issueDate: '2026-10-31', customerName: 'ลูกค้า', items: [coffee, tea]);

  group('InvoiceDraftModel', () {
    test('ยอดบรรทัด 3 x 45 = 135', () {
      expect(coffee.amount, 135);
    });

    test('ราคาไม่รวม VAT: ยอด 177.5 VAT 12.43 รวมทั้งสิ้น 189.93 (VAT คิดจากยอดรวมทั้งใบ)', () {
      final amounts = draft.amounts(vatRegistered: true, pricesIncludeVat: false);
      expect([amounts.itemsTotal, amounts.subtotal, amounts.vat, amounts.total], [177.5, 177.5, 12.43, 189.93]);
    });

    test('ลด 7.5 บาท ราคาไม่รวม VAT: ก่อน VAT 170 VAT 11.90 รวม 181.90', () {
      final amounts = draft.copyWith(discount: 7.5).amounts(vatRegistered: true, pricesIncludeVat: false);
      expect([amounts.discount, amounts.subtotal, amounts.vat, amounts.total], [7.5, 170, 11.9, 181.9]);
    });

    test('ลด 7.5 บาท ราคารวม VAT แล้ว: รวม 170 ถอด VAT ได้ก่อน VAT 158.88 VAT 11.12', () {
      final amounts = draft.copyWith(discount: 7.5).amounts(vatRegistered: true, pricesIncludeVat: true);
      expect([amounts.subtotal, amounts.vat, amounts.total], [158.88, 11.12, 170]);
    });

    test('ร้านไม่จด VAT (ใบเสร็จ): ไม่มี VAT รวม = ยอดหลังหักส่วนลด', () {
      final amounts = draft.copyWith(discount: 7.5).amounts(vatRegistered: false, pricesIncludeVat: false);
      expect([amounts.vat, amounts.total], [0, 170]);
    });

    test('ไม่มีสินค้า ยอดทุกช่องเป็น 0', () {
      const empty = InvoiceDraftModel(issueDate: '2026-10-31');
      final amounts = empty.amounts(vatRegistered: true, pricesIncludeVat: false);
      expect([amounts.subtotal, amounts.vat, amounts.total], [0, 0, 0]);
    });

    test('isOverStock เมื่อจำนวนเกินคงเหลือ', () {
      expect(coffee.isOverStock, false);
      expect(tea.isOverStock, true);
    });

    test('สินค้าที่ไม่นับสต็อก (งานบริการ) ไม่ถือว่าเกินสต็อก', () {
      const service = InvoiceDraftItemModel(
        productId: 'p3',
        name: 'ค่าออกแบบ',
        trackStock: false,
        quantity: 2,
        unitPrice: 300,
      );
      expect(service.isOverStock, false);
    });

    test('สร้างบรรทัดจากสินค้า ได้ 1 ชิ้นตามราคาขาย', () {
      const product = ProductModel(
        id: 'p1',
        name: 'กาแฟเย็น',
        unit: 'แก้ว',
        sellPrice: 45,
        stock: 10,
        trackStock: false,
      );
      final item = InvoiceDraftItemModel.fromProduct(product);
      expect([item.quantity, item.unitPrice, item.unit, item.trackStock], [1, 45, 'แก้ว', false]);
    });

    test('toJson ส่งข้อมูลลูกค้า ส่วนลด และรายการแบบที่ API รับ', () {
      final json = draft.copyWith(discount: 10).toJson();
      expect(json['customer_name'], 'ลูกค้า');
      expect(json['discount'], 10);
      expect(json['items'], [
        {'product_id': 'p1', 'quantity': 3, 'unit_price': 45.0},
        {'product_id': 'p2', 'quantity': 1, 'unit_price': 42.5},
      ]);
    });
  });
}

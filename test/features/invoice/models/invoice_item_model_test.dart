import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/models/invoice_item_model.dart';

void main() {
  const item = InvoiceItemModel(
    id: 'l1',
    productId: 'p1',
    name: 'กาแฟเย็น',
    unit: 'แก้ว',
    quantity: 3,
    unitPrice: 45,
    amount: 135,
  );

  group('InvoiceItemModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': 'l1',
        'product_id': 'p1',
        'name': 'กาแฟเย็น',
        'unit': 'แก้ว',
        'quantity': 3,
        'unit_price': 45,
        'amount': 135,
      };
      expect(InvoiceItemModel.fromJson(json), item);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(InvoiceItemModel.fromJson(item.toJson()), item);
    });
  });
}

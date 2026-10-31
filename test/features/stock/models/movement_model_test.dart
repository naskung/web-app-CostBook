import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/stock/models/movement_model.dart';

void main() {
  final movement = MovementModel(
    id: 'm1',
    productId: 'p1',
    productName: 'กาแฟเย็น',
    unit: 'แก้ว',
    type: 'out',
    quantity: 2,
    invoiceNo: 'INV-2026-0001',
    createdAt: DateTime.utc(2026, 10, 31, 3).toLocal(),
  );

  group('MovementModel', () {
    test('fromJson อ่านเวลาเป็นเวลาเครื่อง และอ่านเลขที่ใบกำกับได้', () {
      final json = {
        'id': 'm1',
        'product_id': 'p1',
        'product_name': 'กาแฟเย็น',
        'unit': 'แก้ว',
        'type': 'out',
        'quantity': 2,
        'note': '',
        'invoice_no': 'INV-2026-0001',
        'created_at': '2026-10-31T03:00:00Z',
      };
      expect(MovementModel.fromJson(json), movement);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(MovementModel.fromJson(movement.toJson()), movement);
    });

    test('อ่านต้นทุนต่อหน่วยและผู้ขายของการรับเข้าได้', () {
      final json = {
        'id': 'm2',
        'type': 'in',
        'quantity': 1000,
        'unit_cost': 0.45,
        'supplier': 'ร้านเส้นพลาสติก',
        'created_at': '2026-10-31T03:00:00Z',
      };
      final model = MovementModel.fromJson(json);
      expect([model.unitCost, model.supplier], [0.45, 'ร้านเส้นพลาสติก']);
    });

    test('isIn / isFromInvoice', () {
      expect(movement.isIn, false);
      expect(movement.isFromInvoice, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/product/models/barcode_product_model.dart';

void main() {
  const water = BarcodeProductModel(
    code: '8850124003850',
    name: 'Nestle Pure Life',
    brand: 'Nestlé',
    quantity: '600 mL',
  );

  group('BarcodeProductModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {'code': '8850124003850', 'name': 'Nestle Pure Life', 'brand': 'Nestlé', 'quantity': '600 mL'};
      expect(BarcodeProductModel.fromJson(json), water);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(BarcodeProductModel.fromJson(water.toJson()), water);
    });

    test('details = ยี่ห้อ · ขนาด ข้ามช่องที่ว่าง', () {
      expect(water.details, 'Nestlé · 600 mL');
      expect(const BarcodeProductModel(code: '1', name: 'น้ำ', quantity: '1 L').details, '1 L');
      expect(const BarcodeProductModel(code: '1', name: 'น้ำ').details, '');
    });
  });
}

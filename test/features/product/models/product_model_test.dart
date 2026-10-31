import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/product/models/product_model.dart';

void main() {
  const product = ProductModel(
    id: '1',
    name: 'กาแฟ',
    unit: 'แก้ว',
    costPrice: 20,
    sellPrice: 45.5,
    stock: 10,
    minStock: 5,
    batchQuantity: 20,
  );

  group('ProductModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': '1',
        'name': 'กาแฟ',
        'unit': 'แก้ว',
        'cost_price': 20,
        'sell_price': 45.5,
        'stock': 10,
        'min_stock': 5,
        'batch_quantity': 20,
      };
      expect(ProductModel.fromJson(json), product);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(ProductModel.fromJson(product.toJson()), product);
    });

    test('isLowStock เป็น true เมื่อ stock เท่ากับ minStock', () {
      const lowProduct = ProductModel(name: 'ชา', stock: 5, minStock: 5);
      expect(lowProduct.isLowStock, true);
    });

    test('isLowStock เป็น false เมื่อ stock มากกว่า minStock', () {
      expect(product.isLowStock, false);
    });

    test('isNew เป็น true เมื่อยังไม่มี id', () {
      expect(const ProductModel(name: 'ใหม่').isNew, true);
      expect(product.isNew, false);
    });
  });
}

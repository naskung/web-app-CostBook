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

    test('อ่านรหัส หมวด รายละเอียด และช่องข้อมูลเพิ่มเติมได้ (ค่าตัวเลขแปลงเป็นข้อความ)', () {
      final json = {
        'id': '2',
        'code': 'P3D-001',
        'name': 'โมเดลมังกร',
        'category': 'งานพิมพ์ 3D',
        'description': 'สูง 15 ซม.',
        'track_stock': false,
        'custom_fields': {'f1': 'PLA', 'f2': 120},
      };
      final model = ProductModel.fromJson(json);
      expect(
        [model.code, model.category, model.description, model.trackStock],
        ['P3D-001', 'งานพิมพ์ 3D', 'สูง 15 ซม.', false],
      );
      expect(model.customFields, {'f1': 'PLA', 'f2': '120'});
    });

    test('ไม่มี track_stock (ข้อมูลเก่า) ถือว่านับสต็อก', () {
      expect(ProductModel.fromJson({'name': 'ชา'}).trackStock, true);
    });

    test('สินค้าที่ไม่นับสต็อก ไม่เตือนของใกล้หมด', () {
      const service = ProductModel(name: 'ค่าออกแบบ', stock: 0, minStock: 5, trackStock: false);
      expect(service.isLowStock, false);
    });

    test('fieldValue ไม่มีค่า ได้ข้อความว่าง', () {
      const model = ProductModel(name: 'โมเดล', customFields: {'f1': 'PLA'});
      expect([model.fieldValue('f1'), model.fieldValue('f9')], ['PLA', '']);
    });

    test('matches ค้นจากชื่อ รหัส หมวด และช่องข้อมูลเพิ่มเติม', () {
      const model = ProductModel(
        name: 'โมเดลมังกร',
        code: 'P3D-001',
        category: 'ของเล่น',
        customFields: {'f1': 'PETG'},
      );
      expect(['มังกร', 'p3d', 'ของเล่น', 'petg', ''].map(model.matches), [true, true, true, true, true]);
      expect(model.matches('กาแฟ'), false);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/settings/models/product_field_model.dart';

void main() {
  const material = ProductFieldModel(
    id: 'f1',
    name: 'วัสดุ',
    type: ProductFieldModel.select,
    options: ['PLA', 'PETG'],
    showInList: true,
    sortOrder: 1,
  );

  group('ProductFieldModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': 'f1',
        'name': 'วัสดุ',
        'type': 'select',
        'options': ['PLA', 'PETG'],
        'show_in_list': true,
        'sort_order': 1,
      };
      expect(ProductFieldModel.fromJson(json), material);
    });

    test('ไม่มี type และ options ได้ช่องข้อความแบบไม่มีตัวเลือก', () {
      final field = ProductFieldModel.fromJson({'id': 'f2', 'name': 'สี', 'options': null});
      expect([field.type, field.options], [ProductFieldModel.text, <String>[]]);
    });

    test('toJson ไม่ส่ง id', () {
      expect(material.toJson(), {
        'name': 'วัสดุ',
        'type': 'select',
        'options': ['PLA', 'PETG'],
        'show_in_list': true,
        'sort_order': 1,
      });
    });

    test('isNew เป็น true เมื่อยังไม่มี id', () {
      expect(const ProductFieldModel(name: 'สี', type: ProductFieldModel.text).isNew, true);
      expect(material.isNew, false);
    });

    test('ชนิดช่องมี 4 แบบ ข้อความ ตัวเลข วันที่ ตัวเลือก', () {
      expect(ProductFieldModel.types, ['text', 'number', 'date', 'select']);
    });
  });
}

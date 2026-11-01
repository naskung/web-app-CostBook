import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/category/models/product_category_model.dart';

void main() {
  group('ProductCategoryModel', () {
    test('fromJson อ่านชื่อและจำนวนสินค้าได้', () {
      final category = ProductCategoryModel.fromJson({'id': 'c1', 'name': 'งานพิมพ์ 3D', 'product_count': 2});
      expect(category, const ProductCategoryModel(id: 'c1', name: 'งานพิมพ์ 3D', productCount: 2));
    });

    test('toJson ส่งแค่ชื่อ', () {
      expect(const ProductCategoryModel(id: 'c1', name: 'พวงกุญแจ', productCount: 3).toJson(), {'name': 'พวงกุญแจ'});
    });

    test('ไม่มี id = หมวดใหม่', () {
      expect(const ProductCategoryModel(name: 'ใหม่').isNew, true);
      expect(const ProductCategoryModel(id: 'c1', name: 'เดิม').isNew, false);
    });
  });
}

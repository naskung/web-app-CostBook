import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/category/models/product_category_model.dart';

class CategoryRepository {
  CategoryRepository(this.api);

  final ApiClient api;

  Future<List<ProductCategoryModel>> getCategories() async {
    final data = await api.get('/product-categories') as List;
    return data.map((item) => ProductCategoryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  // ไม่มี id = เพิ่มใหม่, มี id = เปลี่ยนชื่อ
  Future<void> saveCategory(ProductCategoryModel category) async {
    if (category.isNew) {
      await api.post('/product-categories', category.toJson());
      return;
    }
    await api.put('/product-categories/${category.id}', category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await api.delete('/product-categories/$id');
  }
}

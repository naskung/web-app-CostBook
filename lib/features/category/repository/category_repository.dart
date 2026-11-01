import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/category/models/product_category_model.dart';

class CategoryRepository {
  CategoryRepository(this.api);

  final ApiClient api;

  static const String _path = '/product-categories';

  // หมวดทั้งหมด (ปุ่มกรอง / ช่องเลือกหมวดในฟอร์มสินค้า)
  Future<List<ProductCategoryModel>> getCategories() async => _categories(await api.get(_path));

  // หน้าหมวดหมู่ โหลดทีละหน้า: offset = ข้ามไปกี่หมวด / limit ไม่ส่ง = 1 หน้า (20 หมวด)
  Future<List<ProductCategoryModel>> getCategoryPage({int offset = 0, int limit = ApiConstants.pageSize}) async {
    return _categories(await api.get(_pagePath(offset, limit)));
  }

  // หน้าแรกที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<ProductCategoryModel>? cachedCategoryPage() {
    final data = api.cached(_pagePath(0, ApiConstants.pageSize));
    if (data == null) return null;
    return _categories(data);
  }

  String _pagePath(int offset, int limit) => '$_path?limit=$limit&offset=$offset';

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<ProductCategoryModel>? cachedCategories() {
    final data = api.cached(_path);
    if (data == null) return null;
    return _categories(data);
  }

  List<ProductCategoryModel> _categories(dynamic data) {
    return (data as List).map((item) => ProductCategoryModel.fromJson(item as Map<String, dynamic>)).toList();
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

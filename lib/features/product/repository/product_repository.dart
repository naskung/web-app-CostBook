import 'dart:typed_data';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/product/models/product_counts_model.dart';
import 'package:costbook/features/product/models/product_model.dart';

class ProductRepository {
  ProductRepository(this.api);

  final ApiClient api;

  static const String _listPath = '/products';
  static const String _countsPath = '/products/counts';

  // สินค้าทั้งหมด (หน้าขาย / คำนวณต้นทุน / ออกเอกสาร / AI ต้องใช้ครบ)
  Future<List<ProductModel>> getProducts() async => _products(await api.get(_listPath));

  // หน้ารายการสินค้า: โหลดทีละหน้า พร้อมตัวกรอง (API ค้น / กรองให้) — ค่าว่าง = ไม่กรอง
  // kind = '' ทั้งหมด / 'sale' สินค้าที่ขาย / 'material' วัสดุ
  Future<List<ProductModel>> getProductPage({
    String query = '',
    String categoryId = '',
    String kind = '',
    bool onlyLow = false,
    int offset = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    return _products(await api.get(_pagePath(query, categoryId, kind, onlyLow, offset, limit)));
  }

  // หน้าแรกของตัวกรองนี้ที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<ProductModel>? cachedProductPage({
    String query = '',
    String categoryId = '',
    String kind = '',
    bool onlyLow = false,
  }) {
    final data = api.cached(_pagePath(query, categoryId, kind, onlyLow, 0, ApiConstants.pageSize));
    if (data == null) return null;
    return _products(data);
  }

  Future<ProductCountsModel> getCounts() async {
    return ProductCountsModel.fromJson(await api.get(_countsPath) as Map<String, dynamic>);
  }

  ProductCountsModel? cachedCounts() {
    final data = api.cached(_countsPath);
    if (data == null) return null;
    return ProductCountsModel.fromJson(data as Map<String, dynamic>);
  }

  // ใส่เฉพาะตัวกรองที่ใช้ / Uri ช่วยแปลงภาษาไทยในคำค้นให้ส่งใน URL ได้
  String _pagePath(String query, String categoryId, String kind, bool onlyLow, int offset, int limit) {
    final params = {
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (categoryId.isNotEmpty) 'category_id': categoryId,
      if (kind.isNotEmpty) 'kind': kind,
      if (onlyLow) 'low': 'true',
      'limit': '$limit',
      'offset': '$offset',
    };
    return Uri(path: _listPath, queryParameters: params).toString();
  }

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<ProductModel>? cachedProducts() {
    final data = api.cached(_listPath);
    if (data == null) return null;
    return _products(data);
  }

  List<ProductModel> _products(dynamic data) {
    return (data as List).map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> getProduct(String id) async {
    final data = await api.get('/products/$id') as Map<String, dynamic>;
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> saveProduct(ProductModel product) async {
    if (product.isNew) {
      final data = await api.post('/products', product.toJson()) as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    }
    final data = await api.put('/products/${product.id}', product.toJson()) as Map<String, dynamic>;
    return ProductModel.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    await api.delete('/products/$id');
  }

  Future<ProductModel> uploadImage(String id, Uint8List bytes) async {
    final data = await api.putFile('/products/$id/image', 'image', bytes, 'product.jpg') as Map<String, dynamic>;
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> deleteImage(String id) async {
    final data = await api.delete('/products/$id/image') as Map<String, dynamic>;
    return ProductModel.fromJson(data);
  }
}

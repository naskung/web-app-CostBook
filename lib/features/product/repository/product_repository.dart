import 'dart:typed_data';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/product/models/product_model.dart';

class ProductRepository {
  ProductRepository(this.api);

  final ApiClient api;

  Future<List<ProductModel>> getProducts() async {
    final data = await api.get('/products') as List;
    return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
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

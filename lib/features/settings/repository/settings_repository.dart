import 'dart:typed_data';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';

class SettingsRepository {
  SettingsRepository(this.api);

  final ApiClient api;

  Future<CompanyModel> getCompany() async {
    final data = await api.get('/company') as Map<String, dynamic>;
    return CompanyModel.fromJson(data);
  }

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  CompanyModel? cachedCompany() {
    final data = api.cached('/company');
    if (data == null) return null;
    return CompanyModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CompanyModel> updateCompany(CompanyModel company) async {
    final data = await api.put('/company', company.toJson()) as Map<String, dynamic>;
    return CompanyModel.fromJson(data);
  }

  Future<CompanyModel> uploadLogo(Uint8List bytes) async {
    final data = await api.putFile('/company/logo', 'logo', bytes, 'logo.png') as Map<String, dynamic>;
    return CompanyModel.fromJson(data);
  }

  Future<void> deleteLogo() async {
    await api.delete('/company/logo');
  }

  Future<List<ProductFieldModel>> getFields() async {
    final data = await api.get('/product-fields') as List;
    return data.map((item) => ProductFieldModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveField(ProductFieldModel field) async {
    if (field.isNew) {
      await api.post('/product-fields', field.toJson());
      return;
    }
    await api.put('/product-fields/${field.id}', field.toJson());
  }

  Future<void> deleteField(String id) async {
    await api.delete('/product-fields/$id');
  }
}

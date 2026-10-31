import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/settings/models/company_model.dart';

class SettingsRepository {
  SettingsRepository(this.api);

  final ApiClient api;

  Future<CompanyModel> getCompany() async {
    final data = await api.get('/company') as Map<String, dynamic>;
    return CompanyModel.fromJson(data);
  }

  Future<CompanyModel> updateCompany(CompanyModel company) async {
    final data = await api.put('/company', company.toJson()) as Map<String, dynamic>;
    return CompanyModel.fromJson(data);
  }
}

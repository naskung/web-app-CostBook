import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/cost/models/cost_sheet_model.dart';

class CostRepository {
  CostRepository(this.api);

  final ApiClient api;

  Future<CostSheetModel> getSheet(String productId) async {
    final data = await api.get('/products/$productId/costs') as Map<String, dynamic>;
    return CostSheetModel.fromJson(data);
  }

  Future<CostSheetModel> saveSheet(CostSheetModel sheet) async {
    final data = await api.put('/products/${sheet.productId}/costs', sheet.toJson()) as Map<String, dynamic>;
    return CostSheetModel.fromJson(data);
  }
}

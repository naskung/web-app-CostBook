import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
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

  Future<List<CostPresetModel>> getPresets() async {
    final data = await api.get('/cost-presets') as List;
    return data.map((item) => CostPresetModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  // ไม่มี id = เพิ่มใหม่, มี id = แก้รายการเดิม
  Future<void> savePreset(CostPresetModel preset) async {
    if (preset.id.isEmpty) {
      await api.post('/cost-presets', preset.toJson());
      return;
    }
    await api.put('/cost-presets/${preset.id}', preset.toJson());
  }

  Future<void> deletePreset(String id) async {
    await api.delete('/cost-presets/$id');
  }
}

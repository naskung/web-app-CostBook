import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/features/cost/models/cost_sheet_model.dart';

class CostRepository {
  CostRepository(this.api);

  final ApiClient api;

  Future<CostSheetModel> getSheet(String productId) async {
    final data = await api.get(_sheetPath(productId)) as Map<String, dynamic>;
    return CostSheetModel.fromJson(data);
  }

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  CostSheetModel? cachedSheet(String productId) {
    final data = api.cached(_sheetPath(productId));
    if (data == null) return null;
    return CostSheetModel.fromJson(data as Map<String, dynamic>);
  }

  List<CostPresetModel>? cachedPresets() {
    final data = api.cached(_presetsPath);
    if (data == null) return null;
    return _presets(data);
  }

  String _sheetPath(String productId) => '/products/$productId/costs';

  Future<CostSheetModel> saveSheet(CostSheetModel sheet) async {
    final data = await api.put('/products/${sheet.productId}/costs', sheet.toJson()) as Map<String, dynamic>;
    return CostSheetModel.fromJson(data);
  }

  static const String _presetsPath = '/cost-presets';

  Future<List<CostPresetModel>> getPresets() async => _presets(await api.get(_presetsPath));

  List<CostPresetModel> _presets(dynamic data) {
    return (data as List).map((item) => CostPresetModel.fromJson(item as Map<String, dynamic>)).toList();
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

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';

class StockRepository {
  StockRepository(this.api);

  final ApiClient api;

  static const String _stockPath = '/stock';
  static const String _movementsPath = '/stock/movements';

  Future<List<StockItemModel>> getStock() async => _items(await api.get(_stockPath));

  Future<List<MovementModel>> getMovements() async => _movements(await api.get(_movementsPath));

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<StockItemModel>? cachedStock() {
    final data = api.cached(_stockPath);
    if (data == null) return null;
    return _items(data);
  }

  List<MovementModel>? cachedMovements() {
    final data = api.cached(_movementsPath);
    if (data == null) return null;
    return _movements(data);
  }

  List<StockItemModel> _items(dynamic data) {
    return (data as List).map((item) => StockItemModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  List<MovementModel> _movements(dynamic data) {
    return (data as List).map((item) => MovementModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> addMovement({
    required String type,
    required String productId,
    required int quantity,
    required String note,
    double unitCost = 0,
    String supplier = '',
    bool skipMaterials = false,
  }) async {
    await api.post('/stock/$type', {
      'product_id': productId,
      'quantity': quantity,
      'note': note,
      'unit_cost': unitCost,
      'supplier': supplier,
      'skip_materials': skipMaterials,
    });
  }
}

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';

class StockRepository {
  StockRepository(this.api);

  final ApiClient api;

  Future<List<StockItemModel>> getStock() async {
    final data = await api.get('/stock') as List;
    return data.map((item) => StockItemModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<MovementModel>> getMovements() async {
    final data = await api.get('/stock/movements') as List;
    return data.map((item) => MovementModel.fromJson(item as Map<String, dynamic>)).toList();
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

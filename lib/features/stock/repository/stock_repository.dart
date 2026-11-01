import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';

class StockRepository {
  StockRepository(this.api);

  final ApiClient api;

  static const String _stockPath = '/stock';
  static const String _movementsPath = '/stock/movements';

  Future<List<StockItemModel>> getStock() async => _items(await api.get(_stockPath));

  // ประวัติทีละหน้า (ล่าสุดก่อน): offset = ข้ามไปกี่แถว / limit ไม่ส่ง = 1 หน้า (20 แถว)
  Future<List<MovementModel>> getMovements({int offset = 0, int limit = ApiConstants.pageSize}) async {
    return _movements(await api.get(_movementsPagePath(offset, limit)));
  }

  String _movementsPagePath(int offset, int limit) => '$_movementsPath?limit=$limit&offset=$offset';

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<StockItemModel>? cachedStock() {
    final data = api.cached(_stockPath);
    if (data == null) return null;
    return _items(data);
  }

  List<MovementModel>? cachedMovements() {
    final data = api.cached(_movementsPagePath(0, ApiConstants.pageSize));
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

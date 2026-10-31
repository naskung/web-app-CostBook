import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/market/models/market_check_model.dart';

class MarketRepository {
  MarketRepository(this.api);

  final ApiClient api;

  Future<MarketCheckModel?> getLatest(String productId) async {
    try {
      final data = await api.get('/products/$productId/market') as Map<String, dynamic>;
      return MarketCheckModel.fromJson(data);
    } on ApiException catch (error) {
      if (error.code == 'market_check_not_found') return null;
      rethrow;
    }
  }

  Future<MarketCheckModel> check(String productId) async {
    final data = await api.post('/products/$productId/market', {}) as Map<String, dynamic>;
    return MarketCheckModel.fromJson(data);
  }
}

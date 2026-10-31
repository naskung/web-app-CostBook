import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';

class DashboardRepository {
  DashboardRepository(this.api);

  final ApiClient api;

  Future<DashboardModel> getDashboard(DateTime month) async {
    final data = await api.get('/dashboard?month=${DateUtil.toApiMonth(month)}') as Map<String, dynamic>;
    return DashboardModel.fromJson(data);
  }
}

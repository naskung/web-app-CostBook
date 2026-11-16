import 'package:flutter/material.dart' show DateTimeRange;

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';

class DashboardRepository {
  DashboardRepository(this.api);

  final ApiClient api;

  Future<DashboardModel> getDashboard(DateTimeRange range) async {
    final data = await api.get(_path(range)) as Map<String, dynamic>;
    return DashboardModel.fromJson(data);
  }

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  DashboardModel? cachedDashboard(DateTimeRange range) {
    final data = api.cached(_path(range));
    if (data == null) return null;
    return DashboardModel.fromJson(data as Map<String, dynamic>);
  }

  String _path(DateTimeRange range) => '/dashboard?${DateUtil.toApiRange(range)}';
}

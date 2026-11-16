import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/features/dashboard/repository/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this.repository, {required DateTimeRange range}) : super(DashboardState(range: range)) {
    on<DashboardRequested>(_onRequested);
    on<DashboardRangeChanged>(_onRangeChanged);
  }

  final DashboardRepository repository;

  Future<void> _onRequested(DashboardRequested event, Emitter<DashboardState> emit) async {
    _showCachedFirst(emit, state.range);
    await _load(emit);
  }

  Future<void> _onRangeChanged(DashboardRangeChanged event, Emitter<DashboardState> emit) async {
    _showCachedFirst(emit, event.range);
    await _load(emit);
  }

  // เคยโหลดช่วงนี้แล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  void _showCachedFirst(Emitter<DashboardState> emit, DateTimeRange range) {
    final cached = repository.cachedDashboard(range);
    if (cached == null) {
      emit(state.copyWith(status: AppStatus.loading, range: range));
      return;
    }
    emit(state.copyWith(status: AppStatus.success, range: range, dashboard: cached));
  }

  // ระหว่างรอผู้ใช้เปลี่ยนช่วงวันที่แล้ว → ทิ้งผลของช่วงเก่า
  Future<void> _load(Emitter<DashboardState> emit) async {
    final range = state.range;
    try {
      final dashboard = await repository.getDashboard(range);
      if (state.range != range) return;
      emit(state.copyWith(status: AppStatus.success, dashboard: dashboard));
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }
}

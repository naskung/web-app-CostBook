import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/features/dashboard/repository/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this.repository, {required DateTime month}) : super(DashboardState(month: month)) {
    on<DashboardRequested>(_onRequested);
    on<DashboardMonthChanged>(_onMonthChanged);
  }

  final DashboardRepository repository;

  Future<void> _onRequested(DashboardRequested event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    await _load(emit);
  }

  Future<void> _onMonthChanged(DashboardMonthChanged event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: AppStatus.loading, month: DateUtil.addMonths(state.month, event.monthCount)));
    await _load(emit);
  }

  Future<void> _load(Emitter<DashboardState> emit) async {
    try {
      final dashboard = await repository.getDashboard(state.month);
      emit(state.copyWith(status: AppStatus.success, dashboard: dashboard));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }
}

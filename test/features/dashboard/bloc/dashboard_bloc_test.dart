import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/features/dashboard/repository/dashboard_repository.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository repository;
  final october = DateTimeRange(start: DateTime(2026, 10), end: DateTime(2026, 10, 31));
  final firstHalfOfNovember = DateTimeRange(start: DateTime(2026, 11, 1), end: DateTime(2026, 11, 15));
  const dashboard = DashboardModel(income: 1000, expense: 400, profit: 600);

  setUpAll(() {
    registerFallbackValue(DateTimeRange(start: DateTime(2026), end: DateTime(2026)));
  });

  setUp(() {
    repository = MockDashboardRepository();
  });

  blocTest<DashboardBloc, DashboardState>(
    'DashboardRequested โหลดตัวเลขสรุปของช่วงวันที่',
    build: () {
      when(() => repository.getDashboard(any())).thenAnswer((_) async => dashboard);
      return DashboardBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect:
        () => [
          DashboardState(range: october, status: AppStatus.loading),
          DashboardState(range: october, status: AppStatus.success, dashboard: dashboard),
        ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'DashboardRangeChanged โหลดช่วงวันที่ใหม่',
    build: () {
      when(() => repository.getDashboard(any())).thenAnswer((_) async => dashboard);
      return DashboardBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(DashboardRangeChanged(firstHalfOfNovember)),
    expect:
        () => [
          DashboardState(range: firstHalfOfNovember, status: AppStatus.loading),
          DashboardState(range: firstHalfOfNovember, status: AppStatus.success, dashboard: dashboard),
        ],
    verify: (_) => verify(() => repository.getDashboard(firstHalfOfNovember)).called(1),
  );

  blocTest<DashboardBloc, DashboardState>(
    'DashboardRequested ต่อ server ไม่ได้ ได้ failure',
    build: () {
      when(() => repository.getDashboard(any())).thenThrow(ApiException('network_error'));
      return DashboardBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect:
        () => [
          DashboardState(range: october, status: AppStatus.loading),
          DashboardState(range: october, status: AppStatus.failure, errorCode: 'network_error'),
        ],
  );

  const fresh = DashboardModel(income: 1500, expense: 400, profit: 1100);

  blocTest<DashboardBloc, DashboardState>(
    'เคยโหลดช่วงนี้แล้ว โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วเปลี่ยนเป็นของใหม่เงียบ ๆ',
    build: () {
      when(() => repository.cachedDashboard(october)).thenReturn(dashboard);
      when(() => repository.getDashboard(any())).thenAnswer((_) async => fresh);
      return DashboardBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect:
        () => [
          DashboardState(range: october, status: AppStatus.success, dashboard: dashboard),
          DashboardState(range: october, status: AppStatus.success, dashboard: fresh),
        ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'มีของเดิมโชว์อยู่ แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error',
    build: () {
      when(() => repository.cachedDashboard(october)).thenReturn(dashboard);
      when(() => repository.getDashboard(any())).thenThrow(ApiException('network_error'));
      return DashboardBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect: () => [DashboardState(range: october, status: AppStatus.success, dashboard: dashboard)],
  );
}

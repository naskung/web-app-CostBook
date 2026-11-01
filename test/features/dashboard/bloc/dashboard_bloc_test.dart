import 'package:bloc_test/bloc_test.dart';
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
  final october = DateTime(2026, 10);
  const dashboard = DashboardModel(income: 1000, expense: 400, profit: 600);

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = MockDashboardRepository();
  });

  blocTest<DashboardBloc, DashboardState>(
    'DashboardRequested โหลดตัวเลขสรุปของเดือน',
    build: () {
      when(() => repository.getDashboard(any())).thenAnswer((_) async => dashboard);
      return DashboardBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect:
        () => [
          DashboardState(month: october, status: AppStatus.loading),
          DashboardState(month: october, status: AppStatus.success, dashboard: dashboard),
        ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'DashboardMonthChanged +1 โหลดเดือนถัดไป',
    build: () {
      when(() => repository.getDashboard(any())).thenAnswer((_) async => dashboard);
      return DashboardBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(DashboardMonthChanged(1)),
    expect:
        () => [
          DashboardState(month: DateTime(2026, 11), status: AppStatus.loading),
          DashboardState(month: DateTime(2026, 11), status: AppStatus.success, dashboard: dashboard),
        ],
    verify: (_) => verify(() => repository.getDashboard(DateTime(2026, 11))).called(1),
  );

  blocTest<DashboardBloc, DashboardState>(
    'DashboardRequested ต่อ server ไม่ได้ ได้ failure',
    build: () {
      when(() => repository.getDashboard(any())).thenThrow(ApiException('network_error'));
      return DashboardBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect:
        () => [
          DashboardState(month: october, status: AppStatus.loading),
          DashboardState(month: october, status: AppStatus.failure, errorCode: 'network_error'),
        ],
  );

  const fresh = DashboardModel(income: 1500, expense: 400, profit: 1100);

  blocTest<DashboardBloc, DashboardState>(
    'เคยโหลดเดือนนี้แล้ว โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วเปลี่ยนเป็นของใหม่เงียบ ๆ',
    build: () {
      when(() => repository.cachedDashboard(october)).thenReturn(dashboard);
      when(() => repository.getDashboard(any())).thenAnswer((_) async => fresh);
      return DashboardBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect:
        () => [
          DashboardState(month: october, status: AppStatus.success, dashboard: dashboard),
          DashboardState(month: october, status: AppStatus.success, dashboard: fresh),
        ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'มีของเดิมโชว์อยู่ แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error',
    build: () {
      when(() => repository.cachedDashboard(october)).thenReturn(dashboard);
      when(() => repository.getDashboard(any())).thenThrow(ApiException('network_error'));
      return DashboardBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(DashboardRequested()),
    expect: () => [DashboardState(month: october, status: AppStatus.success, dashboard: dashboard)],
  );
}

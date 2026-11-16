part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  const DashboardState({
    required this.range,
    this.status = AppStatus.initial,
    this.dashboard = const DashboardModel(),
    this.errorCode = '',
  });

  final DateTimeRange range;
  final AppStatus status;
  final DashboardModel dashboard;
  final String errorCode;

  DashboardState copyWith({DateTimeRange? range, AppStatus? status, DashboardModel? dashboard, String? errorCode}) {
    return DashboardState(
      range: range ?? this.range,
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props => [range, status, dashboard, errorCode];
}

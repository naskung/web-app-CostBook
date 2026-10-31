part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  const DashboardState({
    required this.month,
    this.status = AppStatus.initial,
    this.dashboard = const DashboardModel(),
    this.errorCode = '',
  });

  final DateTime month;
  final AppStatus status;
  final DashboardModel dashboard;
  final String errorCode;

  DashboardState copyWith({DateTime? month, AppStatus? status, DashboardModel? dashboard, String? errorCode}) {
    return DashboardState(
      month: month ?? this.month,
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props => [month, status, dashboard, errorCode];
}

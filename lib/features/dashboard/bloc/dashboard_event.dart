part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class DashboardRequested extends DashboardEvent {}

class DashboardRangeChanged extends DashboardEvent {
  DashboardRangeChanged(this.range);

  final DateTimeRange range;
}

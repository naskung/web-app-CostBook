part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class DashboardRequested extends DashboardEvent {}

class DashboardMonthChanged extends DashboardEvent {
  DashboardMonthChanged(this.monthCount);

  final int monthCount;
}

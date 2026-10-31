part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class CompanySaved extends SettingsEvent {
  CompanySaved(this.company);

  final CompanyModel company;
}

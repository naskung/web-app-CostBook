part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class CompanySaved extends SettingsEvent {
  CompanySaved(this.company);

  final CompanyModel company;
}

class ProductFieldSaved extends SettingsEvent {
  ProductFieldSaved(this.field);

  final ProductFieldModel field;
}

class ProductFieldDeleted extends SettingsEvent {
  ProductFieldDeleted(this.id);

  final String id;
}

part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class CompanySaved extends SettingsEvent {
  CompanySaved(this.company);

  final CompanyModel company;
}

class LogoUploaded extends SettingsEvent {
  LogoUploaded(this.bytes);

  final Uint8List bytes;
}

class LogoRemoved extends SettingsEvent {}

class ProductFieldSaved extends SettingsEvent {
  ProductFieldSaved(this.field);

  final ProductFieldModel field;
}

class ProductFormLayoutSaved extends SettingsEvent {
  ProductFormLayoutSaved(this.keys);

  final List<String> keys;
}

class ProductFieldDeleted extends SettingsEvent {
  ProductFieldDeleted(this.id);

  final String id;
}

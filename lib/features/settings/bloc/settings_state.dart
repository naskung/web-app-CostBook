part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.status = AppStatus.initial,
    this.company = const CompanyModel(),
    this.fields = const [],
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.fieldStatus = AppStatus.initial,
    this.fieldErrorCode = '',
  });

  final AppStatus status;
  final CompanyModel company;
  final List<ProductFieldModel> fields;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus fieldStatus;
  final String fieldErrorCode;

  List<ProductFieldModel> get listFields => fields.where((field) => field.showInList).toList();

  SettingsState copyWith({
    AppStatus? status,
    CompanyModel? company,
    List<ProductFieldModel>? fields,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? fieldStatus,
    String? fieldErrorCode,
  }) {
    return SettingsState(
      status: status ?? this.status,
      company: company ?? this.company,
      fields: fields ?? this.fields,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      fieldStatus: fieldStatus ?? this.fieldStatus,
      fieldErrorCode: fieldErrorCode ?? this.fieldErrorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    company,
    fields,
    errorCode,
    saveStatus,
    saveErrorCode,
    fieldStatus,
    fieldErrorCode,
  ];
}

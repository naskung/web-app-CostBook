part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.status = AppStatus.initial,
    this.company = const CompanyModel(),
    this.fields = const [],
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.logoStatus = AppStatus.initial,
    this.logoErrorCode = '',
    this.fieldStatus = AppStatus.initial,
    this.fieldErrorCode = '',
    this.formLayout = const [],
    this.layoutStatus = AppStatus.initial,
    this.layoutErrorCode = '',
  });

  final AppStatus status;
  final CompanyModel company;
  final List<ProductFieldModel> fields;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus logoStatus;
  final String logoErrorCode;
  final AppStatus fieldStatus;
  final String fieldErrorCode;
  final List<String> formLayout;
  final AppStatus layoutStatus;
  final String layoutErrorCode;

  List<ProductFieldModel> get listFields => fields.where((field) => field.showInList).toList();

  List<String> get formOrder => FormLayoutUtil.order(formLayout, [for (final field in fields) field.id]);

  SettingsState copyWith({
    AppStatus? status,
    CompanyModel? company,
    List<ProductFieldModel>? fields,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? logoStatus,
    String? logoErrorCode,
    AppStatus? fieldStatus,
    String? fieldErrorCode,
    List<String>? formLayout,
    AppStatus? layoutStatus,
    String? layoutErrorCode,
  }) {
    return SettingsState(
      status: status ?? this.status,
      company: company ?? this.company,
      fields: fields ?? this.fields,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      logoStatus: logoStatus ?? this.logoStatus,
      logoErrorCode: logoErrorCode ?? this.logoErrorCode,
      fieldStatus: fieldStatus ?? this.fieldStatus,
      fieldErrorCode: fieldErrorCode ?? this.fieldErrorCode,
      formLayout: formLayout ?? this.formLayout,
      layoutStatus: layoutStatus ?? this.layoutStatus,
      layoutErrorCode: layoutErrorCode ?? this.layoutErrorCode,
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
    logoStatus,
    logoErrorCode,
    fieldStatus,
    fieldErrorCode,
    formLayout,
    layoutStatus,
    layoutErrorCode,
  ];
}

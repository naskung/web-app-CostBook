part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.status = AppStatus.initial,
    this.company = const CompanyModel(),
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
  });

  final AppStatus status;
  final CompanyModel company;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;

  SettingsState copyWith({
    AppStatus? status,
    CompanyModel? company,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
  }) {
    return SettingsState(
      status: status ?? this.status,
      company: company ?? this.company,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, company, errorCode, saveStatus, saveErrorCode];
}

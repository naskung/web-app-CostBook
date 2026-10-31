class ApiConstants {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api/v1');
  static const String companyLogoUrl = '$baseUrl/company/logo';
}

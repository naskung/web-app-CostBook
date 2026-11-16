import 'package:equatable/equatable.dart';

class AiSettingsModel extends Equatable {
  const AiSettingsModel({required this.provider, this.apiKey = '', this.baseUrl = '', this.model = ''});

  final String provider;
  final String apiKey;
  final String baseUrl;
  final String model;

  Map<String, dynamic> toJson() {
    return {'provider': provider, 'api_key': apiKey.trim(), 'base_url': baseUrl.trim(), 'model': model.trim()};
  }

  @override
  List<Object?> get props => [provider, apiKey, baseUrl, model];
}

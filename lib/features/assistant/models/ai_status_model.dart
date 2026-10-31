import 'package:equatable/equatable.dart';

class AiStatusModel extends Equatable {
  const AiStatusModel({
    this.enabled = false,
    this.provider = none,
    this.model = '',
    this.source = '',
    this.webSearch = false,
    this.hasOwnKey = false,
    this.keyHint = '',
    this.freeAvailable = false,
  });

  static const String claude = 'claude';
  static const String gemini = 'gemini';
  static const String none = 'none';

  final bool enabled;
  final String provider;
  final String model;
  final String source;
  final bool webSearch;
  final bool hasOwnKey;
  final String keyHint;
  final bool freeAvailable;

  bool get isFree => provider == gemini;

  factory AiStatusModel.fromJson(Map<String, dynamic> json) {
    return AiStatusModel(
      enabled: json['enabled'] as bool? ?? false,
      provider: json['provider'] as String? ?? none,
      model: json['model'] as String? ?? '',
      source: json['source'] as String? ?? '',
      webSearch: json['web_search'] as bool? ?? false,
      hasOwnKey: json['has_own_key'] as bool? ?? false,
      keyHint: json['key_hint'] as String? ?? '',
      freeAvailable: json['free_available'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [enabled, provider, model, source, webSearch, hasOwnKey, keyHint, freeAvailable];
}

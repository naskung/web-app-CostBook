class AiPresetModel {
  const AiPresetModel({required this.id, required this.name, required this.baseUrl, this.noteKey = ''});

  final String id;
  final String name;
  final String baseUrl;
  final String noteKey;

  static const String claudeId = 'claude';
  static const String customId = 'custom';

  static const List<AiPresetModel> all = [
    AiPresetModel(id: 'openai', name: 'OpenAI (ChatGPT)', baseUrl: 'https://api.openai.com/v1'),
    AiPresetModel(id: 'deepseek', name: 'DeepSeek', baseUrl: 'https://api.deepseek.com/v1'),
    AiPresetModel(
      id: 'gemini',
      name: 'Google Gemini',
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
    ),
    AiPresetModel(id: 'groq', name: 'Groq', baseUrl: 'https://api.groq.com/openai/v1'),
    AiPresetModel(
      id: 'openrouter',
      name: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1',
      noteKey: 'ai_preset.openrouter_note',
    ),
    AiPresetModel(id: 'mistral', name: 'Mistral', baseUrl: 'https://api.mistral.ai/v1'),
    AiPresetModel(id: 'xai', name: 'xAI (Grok)', baseUrl: 'https://api.x.ai/v1'),
    AiPresetModel(id: 'together', name: 'Together AI', baseUrl: 'https://api.together.xyz/v1'),
    AiPresetModel(
      id: 'typhoon',
      name: 'Typhoon',
      baseUrl: 'https://api.opentyphoon.ai/v1',
      noteKey: 'ai_preset.typhoon_note',
    ),
    AiPresetModel(id: 'ollama', name: 'Ollama', baseUrl: 'http://localhost:11434/v1', noteKey: 'ai_preset.ollama_note'),
  ];

  static String idOfBaseUrl(String baseUrl) {
    final cleaned = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    for (final preset in all) {
      if (preset.baseUrl == cleaned) return preset.id;
    }
    return customId;
  }

  static AiPresetModel? byId(String id) {
    for (final preset in all) {
      if (preset.id == id) return preset;
    }
    return null;
  }
}

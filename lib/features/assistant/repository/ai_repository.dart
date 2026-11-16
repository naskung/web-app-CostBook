import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/assistant/models/ai_settings_model.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';

class AiRepository {
  AiRepository(this.api);

  final ApiClient api;

  Future<AiStatusModel> getStatus() async {
    final data = await api.get('/ai/status') as Map<String, dynamic>;
    return AiStatusModel.fromJson(data);
  }

  Future<AiStatusModel> saveSettings(AiSettingsModel settings) async {
    final data = await api.put('/ai/key', settings.toJson()) as Map<String, dynamic>;
    return AiStatusModel.fromJson(data);
  }

  Future<List<String>> listModels({required String baseUrl, required String apiKey}) async {
    final data =
        await api.post('/ai/models', {'base_url': baseUrl.trim(), 'api_key': apiKey.trim()}) as Map<String, dynamic>;
    return (data['models'] as List? ?? []).map((model) => model as String).toList();
  }

  Future<AiStatusModel> removeKey() async {
    final data = await api.delete('/ai/key') as Map<String, dynamic>;
    return AiStatusModel.fromJson(data);
  }

  Future<ChatMessageModel> chat(List<ChatMessageModel> messages) async {
    final data = await api.post('/ai/chat', {'messages': ChatMessageModel.toApi(messages)}) as Map<String, dynamic>;
    return ChatMessageModel.reply(data);
  }
}

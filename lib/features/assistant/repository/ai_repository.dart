import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';

class AiRepository {
  AiRepository(this.api);

  final ApiClient api;

  Future<AiStatusModel> getStatus() async {
    final data = await api.get('/ai/status') as Map<String, dynamic>;
    return AiStatusModel.fromJson(data);
  }

  Future<AiStatusModel> saveKey(String apiKey) async {
    final data = await api.put('/ai/key', {'api_key': apiKey}) as Map<String, dynamic>;
    return AiStatusModel.fromJson(data);
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

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';

class AiRepository {
  AiRepository(this.api);

  final ApiClient api;

  Future<bool> isEnabled() async {
    final data = await api.get('/ai/status') as Map<String, dynamic>;
    return data['enabled'] as bool? ?? false;
  }

  Future<ChatMessageModel> chat(List<ChatMessageModel> messages) async {
    final data = await api.post('/ai/chat', {'messages': ChatMessageModel.toApi(messages)}) as Map<String, dynamic>;
    return ChatMessageModel.reply(data);
  }
}

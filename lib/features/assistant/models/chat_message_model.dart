import 'package:equatable/equatable.dart';

import 'package:costbook/features/assistant/models/ai_action_model.dart';

class ChatMessageModel extends Equatable {
  const ChatMessageModel({required this.role, this.text = '', this.actions = const []});

  static const String user = 'user';
  static const String assistant = 'assistant';
  static const String note = 'note';
  static const int maxApiMessages = 40;
  static const int maxMessageLength = 4000;
  static const String actionsOnlyText = '(เสนองานให้ผู้ใช้กดยืนยัน)';

  final String role;
  final String text;
  final List<AiActionModel> actions;

  bool get isUser => role == user;

  bool get isNote => role == note;

  factory ChatMessageModel.reply(Map<String, dynamic> json) {
    final actions = json['actions'] as List? ?? [];
    return ChatMessageModel(
      role: assistant,
      text: (json['reply'] as String? ?? '').trim(),
      actions: actions.map((item) => AiActionModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  ChatMessageModel copyWith({List<AiActionModel>? actions}) {
    return ChatMessageModel(role: role, text: text, actions: actions ?? this.actions);
  }

  static List<Map<String, String>> toApi(List<ChatMessageModel> messages) {
    final history = <Map<String, String>>[];
    final notes = <String>[];
    for (final message in messages) {
      if (message.isNote) {
        notes.add(message.text);
        continue;
      }
      if (message.isUser) {
        _add(history, user, [...notes, message.text].join('\n'));
        notes.clear();
        continue;
      }
      if (history.isEmpty) continue;
      _add(history, assistant, message.text.isEmpty ? actionsOnlyText : message.text);
    }
    while (history.length > maxApiMessages) {
      history.removeRange(0, 2);
    }
    return history;
  }

  static void _add(List<Map<String, String>> history, String role, String text) {
    if (history.isNotEmpty && history.last['role'] == role) {
      history.last['content'] = '${history.last['content']}\n$text';
      return;
    }
    history.add({'role': role, 'content': text});
  }

  @override
  List<Object?> get props => [role, text, actions];
}

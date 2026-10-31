part of 'assistant_bloc.dart';

class AssistantState extends Equatable {
  const AssistantState({
    this.status = AppStatus.initial,
    this.aiEnabled = false,
    this.messages = const [],
    this.sendStatus = AppStatus.initial,
    this.errorCode = '',
  });

  final AppStatus status;
  final bool aiEnabled;
  final List<ChatMessageModel> messages;
  final AppStatus sendStatus;
  final String errorCode;

  bool get isSending => sendStatus == AppStatus.loading;

  List<ChatMessageModel> get visibleMessages => messages.where((message) => !message.isNote).toList();

  AiActionModel? actionOf(String id) {
    for (final message in messages) {
      for (final action in message.actions) {
        if (action.id == id) return action;
      }
    }
    return null;
  }

  AssistantState copyWith({
    AppStatus? status,
    bool? aiEnabled,
    List<ChatMessageModel>? messages,
    AppStatus? sendStatus,
    String? errorCode,
  }) {
    return AssistantState(
      status: status ?? this.status,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      messages: messages ?? this.messages,
      sendStatus: sendStatus ?? this.sendStatus,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props => [status, aiEnabled, messages, sendStatus, errorCode];
}

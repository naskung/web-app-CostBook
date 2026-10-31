part of 'assistant_bloc.dart';

class AssistantState extends Equatable {
  const AssistantState({
    this.status = AppStatus.initial,
    this.ai = const AiStatusModel(),
    this.messages = const [],
    this.sendStatus = AppStatus.initial,
    this.errorCode = '',
    this.isOpen = false,
    this.hasUnread = false,
    this.keyStatus = AppStatus.initial,
    this.keyErrorCode = '',
  });

  final AppStatus status;
  final AiStatusModel ai;
  final List<ChatMessageModel> messages;
  final AppStatus sendStatus;
  final String errorCode;
  final bool isOpen;
  final bool hasUnread;
  final AppStatus keyStatus;
  final String keyErrorCode;

  bool get isSending => sendStatus == AppStatus.loading;

  bool get aiEnabled => ai.enabled;

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
    AiStatusModel? ai,
    List<ChatMessageModel>? messages,
    AppStatus? sendStatus,
    String? errorCode,
    bool? isOpen,
    bool? hasUnread,
    AppStatus? keyStatus,
    String? keyErrorCode,
  }) {
    return AssistantState(
      status: status ?? this.status,
      ai: ai ?? this.ai,
      messages: messages ?? this.messages,
      sendStatus: sendStatus ?? this.sendStatus,
      errorCode: errorCode ?? this.errorCode,
      isOpen: isOpen ?? this.isOpen,
      hasUnread: hasUnread ?? this.hasUnread,
      keyStatus: keyStatus ?? this.keyStatus,
      keyErrorCode: keyErrorCode ?? this.keyErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, ai, messages, sendStatus, errorCode, isOpen, hasUnread, keyStatus, keyErrorCode];
}

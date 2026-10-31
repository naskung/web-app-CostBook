part of 'assistant_bloc.dart';

abstract class AssistantEvent {}

class AssistantOpened extends AssistantEvent {}

class AssistantPanelOpened extends AssistantEvent {}

class AssistantPanelClosed extends AssistantEvent {}

class AssistantMessageSent extends AssistantEvent {
  AssistantMessageSent(this.text);

  final String text;
}

class AssistantRetried extends AssistantEvent {}

class AssistantActionConfirmed extends AssistantEvent {
  AssistantActionConfirmed(this.actionId);

  final String actionId;
}

class AssistantActionCancelled extends AssistantEvent {
  AssistantActionCancelled(this.actionId);

  final String actionId;
}

class AssistantCleared extends AssistantEvent {}

class AssistantKeySaved extends AssistantEvent {
  AssistantKeySaved(this.apiKey);

  final String apiKey;
}

class AssistantKeyRemoved extends AssistantEvent {}

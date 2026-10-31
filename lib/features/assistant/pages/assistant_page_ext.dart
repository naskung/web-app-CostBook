part of 'assistant_page.dart';

extension _AssistantPageExt on _AssistantPageState {
  double _padding(BuildContext context) {
    if (ResponsiveHelper.screenType(context) == ScreenType.mobile) return AppSizes.spaceMedium;
    return AppSizes.spaceLarge;
  }

  Widget _layout(BuildContext context, AssistantState state) {
    final padding = _padding(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.chatMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, state),
              if (!state.aiEnabled) NoticeBanner(message: 'assistant.ai_off'.tr),
              Expanded(child: state.visibleMessages.isEmpty ? _welcome(context, state) : _messages(context, state)),
              if (state.sendStatus == AppStatus.failure) _sendError(context, state),
              const SizedBox(height: AppSizes.spaceSmall),
              _input(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AssistantState state) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Row(
        children: [
          Expanded(
            child: Text('assistant.subtitle'.tr, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ),
          if (state.messages.isNotEmpty)
            TextButton.icon(
              onPressed: state.isSending ? null : () => context.read<AssistantBloc>().add(AssistantCleared()),
              icon: const Icon(Icons.refresh),
              label: Text('assistant.new_chat'.tr),
            ),
        ],
      ),
    );
  }

  Widget _welcome(BuildContext context, AssistantState state) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: AppSizes.spaceXLarge),
          const Icon(Icons.auto_awesome, size: AppSizes.iconBox, color: AppColors.primary),
          const SizedBox(height: AppSizes.spaceMedium),
          Text('assistant.welcome_title'.tr, style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.spaceSmall),
          Text(
            'assistant.welcome'.tr,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceLarge),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.spaceSmall,
            runSpacing: AppSizes.spaceSmall,
            children: [
              for (final key in _AssistantPageState.suggestionKeys)
                ActionChip(label: Text(key.tr), onPressed: state.aiEnabled ? () => _send(key.tr) : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messages(BuildContext context, AssistantState state) {
    final messages = state.visibleMessages.reversed.toList();
    final bloc = context.read<AssistantBloc>();
    return ListView(
      reverse: true,
      children: [
        if (state.isSending) _thinking(context),
        for (final message in messages)
          ChatBubble(
            text: message.text,
            isUser: message.isUser,
            child:
                message.actions.isEmpty
                    ? null
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final action in message.actions)
                          AiActionCard(
                            action: action,
                            onConfirm: () => bloc.add(AssistantActionConfirmed(action.id)),
                            onCancel: () => bloc.add(AssistantActionCancelled(action.id)),
                          ),
                      ],
                    ),
          ),
      ],
    );
  }

  Widget _thinking(BuildContext context) {
    return ChatBubble(
      text: '',
      isUser: false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoading(),
          const SizedBox(width: AppSizes.spaceSmall),
          Flexible(child: Text('assistant.thinking'.tr)),
        ],
      ),
    );
  }

  Widget _sendError(BuildContext context, AssistantState state) {
    return NoticeBanner(
      message: 'error.${state.errorCode}'.tr,
      actionLabel: 'common.retry'.tr,
      onAction: () => context.read<AssistantBloc>().add(AssistantRetried()),
    );
  }

  Widget _input(BuildContext context, AssistantState state) {
    final canSend = state.aiEnabled && !state.isSending;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _inputController,
            focusNode: _inputFocus,
            enabled: state.aiEnabled,
            textInputAction: TextInputAction.send,
            onSubmitted: canSend ? _send : null,
            maxLength: ChatMessageModel.maxMessageLength,
            decoration: InputDecoration(hintText: 'assistant.input_hint'.tr, counterText: ''),
          ),
        ),
        const SizedBox(width: AppSizes.spaceSmall),
        IconButton.filled(
          tooltip: 'assistant.send'.tr,
          onPressed: canSend ? () => _send(_inputController.text) : null,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}

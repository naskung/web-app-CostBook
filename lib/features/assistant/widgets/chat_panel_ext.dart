part of 'chat_panel.dart';

extension _ChatPanelExt on _ChatPanelState {
  String _providerText(AiStatusModel ai) {
    if (ai.provider == AiStatusModel.claude) return 'assistant.provider_claude'.tr;
    if (ai.isFree && ai.webSearch) return 'assistant.provider_free_search'.tr;
    if (ai.isFree) return 'assistant.provider_free'.tr;
    return 'assistant.provider_none'.tr;
  }

  Widget _header(BuildContext context, AssistantState state) {
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.read<AssistantBloc>();
    return Container(
      color: AppColors.dark,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceMedium,
        AppSizes.spaceSmall,
        AppSizes.spaceXSmall,
        AppSizes.spaceSmall,
      ),
      child: Row(
        children: [
          const _AssistantAvatar(),
          const SizedBox(width: AppSizes.spaceSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('assistant.title'.tr, style: textTheme.titleSmall?.copyWith(color: AppColors.onDark)),
                Text(
                  _providerText(state.ai),
                  style: textTheme.bodySmall?.copyWith(color: AppColors.onDarkSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (state.messages.isNotEmpty)
            IconButton(
              tooltip: 'assistant.new_chat'.tr,
              onPressed: state.isSending ? null : () => bloc.add(AssistantCleared()),
              icon: const Icon(Icons.refresh, color: AppColors.onDark),
            ),
          IconButton(
            tooltip: 'assistant.minimize'.tr,
            onPressed: () => bloc.add(AssistantPanelClosed()),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.onDark),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AssistantState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) {
      return const Center(child: AppLoading());
    }
    if (state.visibleMessages.isEmpty) return _welcome(context, state);
    return _messages(context, state);
  }

  Widget _welcome(BuildContext context, AssistantState state) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.spaceMedium),
          const _AssistantAvatar(size: AppSizes.iconBox),
          const SizedBox(height: AppSizes.spaceSmall),
          Text('assistant.welcome_title'.tr, style: textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.spaceXSmall),
          Text(
            'assistant.welcome'.tr,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.spaceXSmall,
            runSpacing: AppSizes.spaceXSmall,
            children: [
              for (final key in _ChatPanelState.suggestionKeys)
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
      padding: const EdgeInsets.all(AppSizes.spaceSmall),
      children: [
        if (state.isSending) _thinking(),
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

  Widget _thinking() {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSmall),
      child: NoticeBanner(
        message: 'error.${state.errorCode}'.tr,
        actionLabel: 'common.retry'.tr,
        onAction: () => context.read<AssistantBloc>().add(AssistantRetried()),
      ),
    );
  }

  Widget _input(BuildContext context, AssistantState state) {
    final canSend = state.aiEnabled && !state.isSending;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSizes.spaceSmall),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocus,
              autofocus: true,
              enabled: state.aiEnabled,
              textInputAction: TextInputAction.send,
              onSubmitted: canSend ? _send : null,
              maxLength: ChatMessageModel.maxMessageLength,
              decoration: InputDecoration(hintText: 'assistant.input_hint'.tr, counterText: '', isDense: true),
            ),
          ),
          const SizedBox(width: AppSizes.spaceXSmall),
          IconButton.filled(
            tooltip: 'assistant.send'.tr,
            onPressed: canSend ? () => _send(_inputController.text) : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar({this.size = AppSizes.chatAvatarSize});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [AppColors.orbLight, AppColors.chartIncome, AppColors.orbDark],
          stops: [0, 0.55, 1],
        ),
      ),
    );
  }
}

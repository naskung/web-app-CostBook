import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';
import 'package:costbook/features/assistant/widgets/ai_action_card.dart';
import 'package:costbook/features/assistant/widgets/chat_bubble.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';

part 'chat_panel_ext.dart';

class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key, this.isFullScreen = false});

  final bool isFullScreen;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  static const List<String> suggestionKeys = [
    'assistant.suggest.summary',
    'assistant.suggest.best_product',
    'assistant.suggest.pricing',
    'assistant.suggest.low_stock',
    'assistant.suggest.cut_cost',
  ];

  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    context.read<AssistantBloc>().add(AssistantMessageSent(text));
    _inputController.clear();
    _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.isFullScreen ? 0.0 : AppSizes.panelRadius;
    return Material(
      color: AppColors.background,
      elevation: widget.isFullScreen ? 0 : AppSizes.chatPanelElevation,
      shadowColor: AppColors.shadow,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: BlocBuilder<AssistantBloc, AssistantState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, state),
              if (state.status == AppStatus.success && !state.aiEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.spaceSmall, AppSizes.spaceSmall, AppSizes.spaceSmall, 0),
                  child: NoticeBanner(message: 'assistant.ai_off'.tr),
                ),
              Expanded(child: _body(context, state)),
              if (state.sendStatus == AppStatus.failure) _sendError(context, state),
              _input(context, state),
            ],
          );
        },
      ),
    );
  }
}

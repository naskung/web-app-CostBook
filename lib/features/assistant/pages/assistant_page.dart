import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';
import 'package:costbook/features/assistant/widgets/ai_action_card.dart';
import 'package:costbook/features/assistant/widgets/chat_bubble.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';

part 'assistant_page_ext.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
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
  void initState() {
    super.initState();
    context.read<AssistantBloc>().add(AssistantOpened());
  }

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
    return BlocBuilder<AssistantBloc, AssistantState>(
      builder: (context, state) {
        if (state.status == AppStatus.initial || state.status == AppStatus.loading) {
          return const Center(child: AppLoading());
        }
        if (state.status == AppStatus.failure) {
          return ErrorView(
            message: 'error.${state.errorCode}'.tr,
            retryLabel: 'common.retry'.tr,
            onRetry: () => context.read<AssistantBloc>().add(AssistantOpened()),
          );
        }
        return _layout(context, state);
      },
    );
  }
}

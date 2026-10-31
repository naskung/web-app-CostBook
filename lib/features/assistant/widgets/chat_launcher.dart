import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/widgets/chat_panel.dart';

class ChatLauncher extends StatelessWidget {
  const ChatLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssistantBloc, AssistantState>(
      buildWhen: (previous, current) => previous.isOpen != current.isOpen || previous.hasUnread != current.hasUnread,
      builder: (context, state) {
        final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
        if (state.isOpen && isMobile) {
          return const Positioned.fill(child: SafeArea(child: ChatPanel(isFullScreen: true)));
        }
        if (state.isOpen) {
          final height = math.min(
            AppSizes.chatPanelHeight,
            MediaQuery.sizeOf(context).height - AppSizes.spaceXLarge * 2,
          );
          return Positioned(
            right: AppSizes.spaceLarge,
            bottom: AppSizes.spaceLarge,
            child: SizedBox(width: AppSizes.chatPanelWidth, height: height, child: const ChatPanel()),
          );
        }
        return Positioned(
          right: AppSizes.spaceLarge,
          bottom: AppSizes.spaceLarge,
          child: Badge(
            isLabelVisible: state.hasUnread,
            smallSize: AppSizes.unreadDotSize,
            backgroundColor: AppColors.danger,
            child: FloatingActionButton(
              heroTag: null,
              tooltip: 'assistant.open'.tr,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: const CircleBorder(),
              onPressed: () => context.read<AssistantBloc>().add(AssistantPanelOpened()),
              child: const Icon(Icons.chat_bubble_outline),
            ),
          ),
        );
      },
    );
  }
}

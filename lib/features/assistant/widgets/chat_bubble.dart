import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text, required this.isUser, this.child});

  final String text;
  final bool isUser;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.chatBubbleMaxWidth),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
          padding: const EdgeInsets.all(AppSizes.spaceMedium),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: isUser ? null : Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (text.isNotEmpty) SelectableText(text, style: textTheme.bodyMedium),
              if (child != null) ...[
                if (text.isNotEmpty) const SizedBox(height: AppSizes.spaceSmall),
                child ?? const SizedBox(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

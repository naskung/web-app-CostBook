import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/dashboard/widgets/dashboard_panel.dart';

class AiAskCard extends StatefulWidget {
  const AiAskCard({super.key});

  @override
  State<AiAskCard> createState() => _AiAskCardState();
}

class _AiAskCardState extends State<AiAskCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<AssistantBloc>()
      ..add(AssistantMessageSent(text))
      ..add(AssistantPanelOpened());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DashboardPanel(
      title: 'dashboard.ai_title'.tr,
      trailing: IconButton(
        tooltip: 'dashboard.ai_open'.tr,
        onPressed: () => context.read<AssistantBloc>().add(AssistantPanelOpened()),
        icon: const Icon(Icons.open_in_full, size: AppSizes.iconSmall, color: AppColors.textSecondary),
      ),
      child: Column(
        children: [
          Container(
            width: AppSizes.orbSize,
            height: AppSizes.orbSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.35, -0.4),
                colors: [AppColors.orbLight, AppColors.chartIncome, AppColors.orbDark],
                stops: [0, 0.55, 1],
              ),
              boxShadow: [BoxShadow(color: AppColors.orbGlow, blurRadius: AppSizes.shadowBlur)],
            ),
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          Text(
            'dashboard.ai_hint'.tr,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceMedium),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _ask(),
            decoration: InputDecoration(
              hintText: 'dashboard.ai_input'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(AppSizes.spaceXSmall),
                child: IconButton.filled(
                  tooltip: 'assistant.send'.tr,
                  onPressed: _ask,
                  icon: const Icon(Icons.arrow_upward, size: AppSizes.iconSmall),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

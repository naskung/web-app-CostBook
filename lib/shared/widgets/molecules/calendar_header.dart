import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.label,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
    this.labelTooltip = '',
    this.onLabelTap,
  });

  final String label;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String labelTooltip;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onPrevious, tooltip: previousTooltip, icon: const Icon(Icons.chevron_left)),
        Expanded(child: Center(child: _label(context))),
        IconButton(onPressed: onNext, tooltip: nextTooltip, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  Widget _label(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    final onTap = onLabelTap;
    if (onTap == null) return Text(label, style: style, textAlign: TextAlign.center);
    return Tooltip(
      message: labelTooltip,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

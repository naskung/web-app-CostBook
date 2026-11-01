import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class RankedBarItem {
  const RankedBarItem({required this.label, required this.value, required this.valueText, this.tooltip = ''});

  final String label;
  final double value;
  final String valueText;
  final String tooltip;
}

class RankedBarList extends StatelessWidget {
  const RankedBarList({super.key, required this.items, required this.color, required this.emptyText});

  final List<RankedBarItem> items;
  final Color color;
  final String emptyText;

  // ชื่อกว้างไม่เกิน 35% ของกล่อง → จอแคบชื่อหดลง (ตัดเป็น …) ตัวเลขด้านขวาไม่ล้นจอ
  static const double _labelShare = 0.35;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (items.isEmpty) {
      return Text(emptyText, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary));
    }
    final largest = items.map((item) => item.value).fold(0.0, (max, value) => value > max ? value : max);
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth = math.min(AppSizes.rankedLabelWidth, constraints.maxWidth * _labelShare);
        return Column(children: [for (final item in items) _row(context, item, largest, labelWidth)]);
      },
    );
  }

  Widget _row(BuildContext context, RankedBarItem item, double largest, double labelWidth) {
    final textTheme = Theme.of(context).textTheme;
    final fraction = largest <= 0 ? 0.0 : (item.value / largest).clamp(0.0, 1.0);
    return Tooltip(
      message: item.tooltip.isEmpty ? '${item.label} ${item.valueText}' : item.tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
        child: Row(
          children: [
            SizedBox(
              width: labelWidth,
              child: Text(item.label, style: textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: AppSizes.spaceSmall),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: constraints.maxWidth * fraction,
                      height: AppSizes.rankedBarHeight,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(AppSizes.chartBarRadius)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSizes.spaceSmall),
            Text(item.valueText, style: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

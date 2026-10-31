import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';

class WeekdayChart extends StatelessWidget {
  const WeekdayChart({super.key, required this.totals, required this.labels, required this.tooltipText});

  final List<double> totals;
  final List<String> labels;
  final String Function(int index) tooltipText;

  int get bestIndex {
    var best = 0;
    for (var i = 1; i < totals.length; i++) {
      if (totals[i] > totals[best]) best = i;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final largest = totals.fold(0.0, math.max);
    final best = bestIndex;
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = math.min(AppSizes.chartBarMaxWidth, constraints.maxWidth / totals.length * 0.6);
        return BarChart(
          BarChartData(
            minY: 0,
            maxY: largest <= 0 ? 1 : largest * 1.05,
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < totals.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: totals[i],
                      width: barWidth,
                      color: i == best && largest > 0 ? AppColors.chartIncome : AppColors.chartMuted,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusSmall)),
                    ),
                  ],
                ),
            ],
            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: AppSizes.chartBottomReserved,
                  getTitlesWidget: (value, meta) {
                    final isBest = value.toInt() == best && largest > 0;
                    final text = isBest ? MoneyUtil.formatShort(MoneyUtil.round2(totals[best])) : '';
                    return SideTitleWidget(meta: meta, child: Text(text, style: textTheme.titleSmall));
                  },
                ),
              ),
              leftTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: AppSizes.chartBottomReserved,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    final isBest = index == best && largest > 0;
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        labels[index],
                        style: textTheme.bodySmall?.copyWith(
                          color: isBest ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: isBest ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => AppColors.tooltip,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem:
                    (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      tooltipText(groupIndex),
                      textTheme.bodySmall?.copyWith(color: AppColors.onTooltip) ?? const TextStyle(),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

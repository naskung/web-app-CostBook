import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/market_util.dart';
import 'package:costbook/core/utils/money_util.dart';

class MarketRangeBar extends StatelessWidget {
  const MarketRangeBar({
    super.key,
    required this.low,
    required this.high,
    required this.typical,
    required this.price,
    required this.tooltip,
  });

  final double low;
  final double high;
  final double typical;
  final double price;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    final domainLow = math.min(low, price);
    final domainHigh = math.max(high, price);
    double place(double value) => MarketUtil.placeInRange(value: value, low: domainLow, high: domainHigh);

    return Tooltip(
      message: tooltip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppSizes.rangeRowHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth - AppSizes.rangeMarkerSize;
                double left(double value) => place(value) * width;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      child: Container(height: AppSizes.rangeTrackHeight, color: AppColors.chartTrack),
                    ),
                    Positioned(
                      left: left(low) + AppSizes.rangeMarkerSize / 2,
                      width: math.max(left(high) - left(low), AppSizes.rangeTickWidth),
                      child: Container(
                        height: AppSizes.rangeTrackHeight,
                        decoration: BoxDecoration(
                          color: AppColors.chartIncome.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(AppSizes.chartBarRadius),
                        ),
                      ),
                    ),
                    if (typical > 0)
                      Positioned(
                        left: left(typical) + AppSizes.rangeMarkerSize / 2 - AppSizes.rangeTickWidth / 2,
                        child: Container(
                          width: AppSizes.rangeTickWidth,
                          height: AppSizes.rangeMarkerSize + AppSizes.spaceXSmall,
                          color: AppColors.chartIncome,
                        ),
                      ),
                    Positioned(
                      left: left(price),
                      child: Container(
                        width: AppSizes.rangeMarkerSize,
                        height: AppSizes.rangeMarkerSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: AppSizes.chartLineWidth),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            children: [
              Text(MoneyUtil.format(domainLow), style: style),
              const Spacer(),
              Text(MoneyUtil.format(domainHigh), style: style),
            ],
          ),
        ],
      ),
    );
  }
}

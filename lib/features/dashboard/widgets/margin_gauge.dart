import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/percent_util.dart';

class MarginGauge extends StatelessWidget {
  const MarginGauge({super.key, required this.percent, required this.caption});

  static const int tickCount = 36;

  final double percent;
  final String caption;

  Color get color {
    if (percent >= 30) return AppColors.success;
    if (percent >= 10) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: AppSizes.gaugeHeight,
      child: CustomPaint(
        painter: _GaugePainter(fraction: (percent / 100).clamp(0.0, 1.0), color: color),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(PercentUtil.format(percent), style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(caption, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final outer = math.min(size.width / 2, size.height);
    final inner = outer - AppSizes.gaugeTickLength;
    final filledTicks = (fraction * (MarginGauge.tickCount + 1)).round();
    for (var i = 0; i <= MarginGauge.tickCount; i++) {
      final angle = math.pi + math.pi * i / MarginGauge.tickCount;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final paint =
          Paint()
            ..color = i < filledTicks ? color : AppColors.border
            ..strokeWidth = AppSizes.gaugeTickWidth
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(center + direction * inner, center + direction * outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.color != color;
  }
}

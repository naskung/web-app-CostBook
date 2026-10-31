import 'dart:math' as math;

import 'package:intl/intl.dart';

class ChartRange {
  const ChartRange({required this.min, required this.max, required this.step});

  final double min;
  final double max;
  final double step;
}

class ChartUtil {
  static double niceStep(double range, {int ticks = 4}) {
    if (range <= 0) return 1;
    final rough = range / ticks;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final fraction = rough / magnitude;
    if (fraction <= 1) return magnitude;
    if (fraction <= 2) return 2 * magnitude;
    if (fraction <= 5) return 5 * magnitude;
    return 10 * magnitude;
  }

  static String axisLabel(double value, ChartRange range) {
    if (value == 0) return '0';
    final largest = math.max(range.min.abs(), range.max.abs());
    if (largest < 10000) return NumberFormat('#,##0').format(value);
    final thousands = value / 1000;
    final text = thousands == thousands.roundToDouble() ? thousands.toStringAsFixed(0) : thousands.toStringAsFixed(1);
    return '${text}K';
  }

  static List<double> cumulative(Iterable<double> values) {
    final totals = <double>[];
    var running = 0.0;
    for (final value in values) {
      running += value;
      totals.add((running * 100).roundToDouble() / 100);
    }
    return totals;
  }

  static ChartRange range(Iterable<double> values, {int ticks = 4}) {
    final low = values.fold(0.0, math.min);
    final high = values.fold(0.0, math.max);
    final step = niceStep(high - low, ticks: ticks);
    return ChartRange(min: (low / step).floor() * step, max: math.max((high / step).ceil() * step, step), step: step);
  }
}

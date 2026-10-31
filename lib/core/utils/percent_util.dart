import 'package:costbook/core/utils/money_util.dart';

class PercentUtil {
  static double? change({required double current, required double previous}) {
    if (previous == 0) return null;
    return MoneyUtil.round2((current - previous) / previous.abs() * 100);
  }

  static double of({required double part, required double total}) {
    if (total == 0) return 0;
    return MoneyUtil.round2(part / total * 100);
  }

  static String format(double percent, {bool showSign = false}) {
    final text = '${percent.abs().toStringAsFixed(percent.abs() >= 100 ? 0 : 1)}%';
    if (!showSign || percent == 0) return text;
    return percent > 0 ? '+$text' : '-$text';
  }
}

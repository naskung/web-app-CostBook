import 'package:intl/intl.dart';

class MoneyUtil {
  static final NumberFormat _moneyFormat = NumberFormat('#,##0.00');
  static final NumberFormat _wholeFormat = NumberFormat('#,##0');

  static double round2(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  static String format(double value) {
    return _moneyFormat.format(value);
  }

  static String formatShort(double value) {
    if (value == value.roundToDouble()) return _wholeFormat.format(value);
    return format(value);
  }

  static double sum(Iterable<double> values) {
    return round2(values.fold(0, (total, value) => total + value));
  }

  static double parse(String text) {
    return double.tryParse(text.replaceAll(',', '').trim()) ?? 0;
  }
}

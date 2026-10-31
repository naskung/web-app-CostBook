import 'package:costbook/core/lang/app_lang.dart';

class DateUtil {
  static String toApiDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  static String toApiMonth(DateTime month) {
    return '${month.year}-${_twoDigits(month.month)}';
  }

  static DateTime fromApiDate(String text) {
    return DateTime.tryParse(text) ?? DateTime(1970);
  }

  static String toDisplayDate(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${_displayYear(date.year)}';
  }

  static String monthLabel(DateTime month) {
    return '${'month.${month.month}'.tr} ${_displayYear(month.year)}';
  }

  static String shortMonthLabel(DateTime month) {
    return 'month_short.${month.month}'.tr;
  }

  static DateTime addMonths(DateTime month, int count) {
    return DateTime(month.year, month.month + count);
  }

  static int _displayYear(int year) {
    if (AppLang.currentCode == 'th') return year + 543;
    return year;
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

import 'package:flutter/material.dart' show DateTimeRange;

import 'package:costbook/core/lang/app_lang.dart';

class DateUtil {
  static const int maxRangeDays = 366;

  static String toApiDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  static String toApiRange(DateTimeRange range) {
    return 'from=${toApiDate(range.start)}&to=${toApiDate(range.end)}';
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

  static String yearLabel(int year) {
    return '${_displayYear(year)}';
  }

  static String shortMonthLabel(DateTime month) {
    return 'month_short.${month.month}'.tr;
  }

  static String shortDateLabel(DateTime date) {
    return '${date.day} ${shortMonthLabel(date)}';
  }

  static String rangeLabel(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    if (isWholeMonth(range)) return monthLabel(start);
    final endText = '${shortDateLabel(end)} ${_displayYear(end.year)}';
    if (isSameDay(start, end)) return endText;
    if (start.year == end.year && start.month == end.month) return '${start.day} – $endText';
    if (start.year == end.year) return '${shortDateLabel(start)} – $endText';
    return '${shortDateLabel(start)} ${_displayYear(start.year)} – $endText';
  }

  static DateTime addMonths(DateTime month, int count) {
    return DateTime(month.year, month.month + count);
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isSameDay(DateTime first, DateTime second) {
    return dateOnly(first) == dateOnly(second);
  }

  static DateTimeRange dayRange(DateTime day) {
    final date = dateOnly(day);
    return DateTimeRange(start: date, end: date);
  }

  static DateTimeRange monthRange(DateTime day) {
    return DateTimeRange(start: DateTime(day.year, day.month), end: DateTime(day.year, day.month + 1, 0));
  }

  static DateTimeRange lastDays(DateTime today, int count) {
    final end = dateOnly(today);
    return DateTimeRange(start: DateTime(end.year, end.month, end.day - (count - 1)), end: end);
  }

  static bool isWholeMonth(DateTimeRange range) {
    final month = monthRange(range.start);
    return isSameDay(range.start, month.start) && isSameDay(range.end, month.end);
  }

  static bool isInRange(DateTime day, DateTimeRange range) {
    final date = dateOnly(day);
    return !date.isBefore(dateOnly(range.start)) && !date.isAfter(dateOnly(range.end));
  }

  static int dayCount(DateTimeRange range) {
    final start = DateTime.utc(range.start.year, range.start.month, range.start.day);
    final end = DateTime.utc(range.end.year, range.end.month, range.end.day);
    return end.difference(start).inDays + 1;
  }

  static int daysUntil(DateTimeRange range, DateTime today) {
    if (dateOnly(today).isBefore(dateOnly(range.start))) return 0;
    if (!isInRange(today, range)) return dayCount(range);
    return dayCount(DateTimeRange(start: range.start, end: today));
  }

  static DateTime defaultDateIn(DateTimeRange range, DateTime today) {
    if (isInRange(today, range)) return dateOnly(today);
    return dateOnly(range.start);
  }

  static List<DateTime?> calendarDays(DateTime month) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final blanksBeforeFirstDay = first.weekday % 7;
    return [
      for (var i = 0; i < blanksBeforeFirstDay; i++) null,
      for (var day = 1; day <= daysInMonth; day++) DateTime(month.year, month.month, day),
    ];
  }

  static int _displayYear(int year) {
    if (AppLang.currentCode == 'th') return year + 543;
    return year;
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

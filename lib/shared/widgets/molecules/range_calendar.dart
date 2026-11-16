import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/shared/widgets/molecules/calendar_header.dart';

class RangeCalendar extends StatelessWidget {
  const RangeCalendar({
    super.key,
    required this.month,
    required this.start,
    required this.end,
    required this.today,
    required this.onDayTap,
    required this.onMonthChanged,
    required this.onMonthLabelTap,
  });

  final DateTime month;
  final DateTime start;
  final DateTime? end;
  final DateTime today;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<int> onMonthChanged;
  final VoidCallback onMonthLabelTap;

  @override
  Widget build(BuildContext context) {
    final days = DateUtil.calendarDays(month);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(context),
        const SizedBox(height: AppSizes.spaceXSmall),
        _weekdayRow(context),
        for (var first = 0; first < days.length; first += 7) _weekRow(days, first),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return CalendarHeader(
      label: DateUtil.monthLabel(month),
      labelTooltip: 'date_range.pick_month'.tr,
      onLabelTap: onMonthLabelTap,
      previousTooltip: 'common.previous_month'.tr,
      nextTooltip: 'common.next_month'.tr,
      onPrevious: () => onMonthChanged(-1),
      onNext: () => onMonthChanged(1),
    );
  }

  Widget _weekdayRow(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    return Row(
      children: [
        for (var weekday = 0; weekday < 7; weekday++)
          Expanded(
            child: SizedBox(
              height: AppSizes.calendarDayHeight,
              child: Center(child: Text('weekday_short.$weekday'.tr, style: style)),
            ),
          ),
      ],
    );
  }

  Widget _weekRow(List<DateTime?> days, int first) {
    return Row(
      children: [
        for (var index = first; index < first + 7; index++)
          Expanded(child: index < days.length ? _dayCell(days[index]) : const SizedBox()),
      ],
    );
  }

  Widget _dayCell(DateTime? day) {
    if (day == null) return const SizedBox(height: AppSizes.calendarDayHeight);
    final selectedEnd = end;
    final hasRange = selectedEnd != null && !DateUtil.isSameDay(start, selectedEnd);
    final isInRange = selectedEnd != null && DateUtil.isInRange(day, DateTimeRange(start: start, end: selectedEnd));
    return _CalendarDay(
      day: day,
      isEdge: DateUtil.isSameDay(day, start) || (selectedEnd != null && DateUtil.isSameDay(day, selectedEnd)),
      bandOnLeft: hasRange && isInRange && !DateUtil.isSameDay(day, start),
      bandOnRight: hasRange && isInRange && !DateUtil.isSameDay(day, selectedEnd),
      isToday: DateUtil.isSameDay(day, today),
      onTap: () => onDayTap(day),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.isEdge,
    required this.bandOnLeft,
    required this.bandOnRight,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final bool isEdge;
  final bool bandOnLeft;
  final bool bandOnRight;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: isEdge ? AppColors.onPrimary : AppColors.textPrimary,
      fontWeight: isEdge || isToday ? FontWeight.w700 : FontWeight.w400,
    );
    return SizedBox(
      height: AppSizes.calendarDayHeight,
      child: Stack(
        children: [
          Positioned.fill(
            top: AppSizes.calendarBandInset,
            bottom: AppSizes.calendarBandInset,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ColoredBox(color: bandOnLeft ? AppColors.primarySoft : AppColors.transparent)),
                Expanded(child: ColoredBox(color: bandOnRight ? AppColors.primarySoft : AppColors.transparent)),
              ],
            ),
          ),
          Center(
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: AppSizes.calendarDayCircle,
                height: AppSizes.calendarDayCircle,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEdge ? AppColors.primary : null,
                  border: isToday && !isEdge ? Border.all(color: AppColors.primary) : null,
                ),
                child: Text('${day.day}', style: textStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

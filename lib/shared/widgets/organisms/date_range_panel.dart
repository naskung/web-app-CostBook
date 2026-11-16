import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/shared/widgets/molecules/month_year_grid.dart';
import 'package:costbook/shared/widgets/molecules/range_calendar.dart';

class DateRangePanel extends StatefulWidget {
  const DateRangePanel({
    super.key,
    required this.initialRange,
    required this.today,
    required this.onApply,
    required this.onCancel,
  });

  final DateTimeRange initialRange;
  final DateTime today;
  final ValueChanged<DateTimeRange> onApply;
  final VoidCallback onCancel;

  @override
  State<DateRangePanel> createState() => _DateRangePanelState();
}

class _DateRangePanelState extends State<DateRangePanel> {
  late DateTime _start = DateUtil.dateOnly(widget.initialRange.start);
  late DateTime? _end = DateUtil.dateOnly(widget.initialRange.end);
  late DateTime _shownMonth = DateTime(widget.initialRange.end.year, widget.initialRange.end.month);
  bool _isPickingMonth = false;

  DateTimeRange get _selected => DateTimeRange(start: _start, end: _end ?? _start);

  bool get _isTooLong => DateUtil.dayCount(_selected) > DateUtil.maxRangeDays;

  Map<String, DateTimeRange> get _presets {
    final today = widget.today;
    return {
      'date_range.today': DateUtil.dayRange(today),
      'date_range.yesterday': DateUtil.dayRange(DateTime(today.year, today.month, today.day - 1)),
      'date_range.last_7_days': DateUtil.lastDays(today, 7),
      'date_range.this_month': DateUtil.monthRange(today),
      'date_range.last_month': DateUtil.monthRange(DateUtil.addMonths(today, -1)),
    };
  }

  void _pickDay(DateTime day) {
    setState(() {
      if (_end != null) {
        _start = day;
        _end = null;
        return;
      }
      if (day.isBefore(_start)) {
        _end = _start;
        _start = day;
        return;
      }
      _end = day;
    });
  }

  void _showMonth(int count) {
    setState(() => _shownMonth = DateUtil.addMonths(_shownMonth, count));
  }

  void _pickMonth(DateTime month) {
    setState(() {
      _shownMonth = month;
      _isPickingMonth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.dateRangePanelWidth,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _presetChips(),
            const Divider(height: AppSizes.spaceLarge),
            if (_isPickingMonth)
              MonthYearGrid(shownMonth: _shownMonth, today: widget.today, onMonthPicked: _pickMonth)
            else
              RangeCalendar(
                month: _shownMonth,
                start: _start,
                end: _end,
                today: widget.today,
                onDayTap: _pickDay,
                onMonthChanged: _showMonth,
                onMonthLabelTap: () => setState(() => _isPickingMonth = true),
              ),
            const Divider(height: AppSizes.spaceLarge),
            _summary(context),
            const SizedBox(height: AppSizes.spaceSmall),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Widget _presetChips() {
    return Wrap(
      spacing: AppSizes.spaceSmall,
      runSpacing: AppSizes.spaceSmall,
      children: [
        for (final preset in _presets.entries)
          ChoiceChip(
            label: Text(preset.key.tr),
            selected: _end != null && _selected == preset.value,
            onSelected: (_) => widget.onApply(preset.value),
          ),
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (_isTooLong) {
      return Text(
        'date_range.too_long'.trParams({'days': '${DateUtil.maxRangeDays}'}),
        style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateUtil.rangeLabel(_selected), style: textTheme.titleSmall),
        Text(
          _end == null
              ? 'date_range.pick_end'.tr
              : 'date_range.day_count'.trParams({'count': '${DateUtil.dayCount(_selected)}'}),
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: widget.onCancel, child: Text('common.cancel'.tr)),
        const SizedBox(width: AppSizes.spaceSmall),
        FilledButton(
          onPressed: _isTooLong ? null : () => widget.onApply(_selected),
          child: Text('date_range.apply'.tr),
        ),
      ],
    );
  }
}

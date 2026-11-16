import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/shared/widgets/molecules/calendar_header.dart';

class MonthYearGrid extends StatefulWidget {
  const MonthYearGrid({super.key, required this.shownMonth, required this.today, required this.onMonthPicked});

  final DateTime shownMonth;
  final DateTime today;
  final ValueChanged<DateTime> onMonthPicked;

  @override
  State<MonthYearGrid> createState() => _MonthYearGridState();
}

class _MonthYearGridState extends State<MonthYearGrid> {
  static const int _yearsPerPage = 12;

  late int _year = widget.shownMonth.year;
  late int _lastYearOfPage = widget.shownMonth.year;
  bool _isPickingYear = false;

  int get _firstYearOfPage => _lastYearOfPage - _yearsPerPage + 1;

  void _changeYear(int count) {
    setState(() => _year += count);
  }

  void _changeYearPage(int count) {
    setState(() => _lastYearOfPage += count * _yearsPerPage);
  }

  void _showYears() {
    setState(() {
      _isPickingYear = true;
      _lastYearOfPage = _year;
    });
  }

  void _pickYear(int year) {
    setState(() {
      _year = year;
      _isPickingYear = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPickingYear) return _yearPage();
    return _monthPage();
  }

  Widget _monthPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarHeader(
          label: DateUtil.yearLabel(_year),
          labelTooltip: 'date_range.pick_year'.tr,
          onLabelTap: _showYears,
          previousTooltip: 'date_range.previous_year'.tr,
          nextTooltip: 'date_range.next_year'.tr,
          onPrevious: () => _changeYear(-1),
          onNext: () => _changeYear(1),
        ),
        _grid([
          for (var month = 1; month <= 12; month++)
            _GridCell(
              label: 'month_short.$month'.tr,
              isSelected: _year == widget.shownMonth.year && month == widget.shownMonth.month,
              isCurrent: _year == widget.today.year && month == widget.today.month,
              onTap: () => widget.onMonthPicked(DateTime(_year, month)),
            ),
        ]),
      ],
    );
  }

  Widget _yearPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarHeader(
          label: '${DateUtil.yearLabel(_firstYearOfPage)} – ${DateUtil.yearLabel(_lastYearOfPage)}',
          previousTooltip: 'date_range.previous_years'.tr,
          nextTooltip: 'date_range.next_years'.tr,
          onPrevious: () => _changeYearPage(-1),
          onNext: () => _changeYearPage(1),
        ),
        _grid([
          for (var year = _firstYearOfPage; year <= _lastYearOfPage; year++)
            _GridCell(
              label: DateUtil.yearLabel(year),
              isSelected: year == _year,
              isCurrent: year == widget.today.year,
              onTap: () => _pickYear(year),
            ),
        ]),
      ],
    );
  }

  Widget _grid(List<Widget> cells) {
    return Column(
      children: [
        for (var first = 0; first < cells.length; first += 3)
          Row(children: [for (final cell in cells.skip(first).take(3)) Expanded(child: cell)]),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.label, required this.isSelected, required this.isCurrent, required this.onTap});

  final String label;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
      fontWeight: isSelected || isCurrent ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceXSmall),
      child: Material(
        color: isSelected ? AppColors.primary : AppColors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: isCurrent && !isSelected ? AppColors.primary : AppColors.transparent),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(height: AppSizes.monthGridCellHeight, child: Center(child: Text(label, style: style))),
        ),
      ),
    );
  }
}

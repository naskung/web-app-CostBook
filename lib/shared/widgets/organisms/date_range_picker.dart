import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/shared/widgets/organisms/date_range_panel.dart';

class DateRangePicker extends StatefulWidget {
  const DateRangePicker({super.key, required this.range, required this.onChanged});

  final DateTimeRange range;
  final ValueChanged<DateTimeRange> onChanged;

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  final _menuController = MenuController();

  void _apply(DateTimeRange range) {
    _menuController.close();
    if (range != widget.range) widget.onChanged(range);
  }

  void _toggle() {
    if (_menuController.isOpen) {
      _menuController.close();
      return;
    }
    _menuController.open();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, AppSizes.dateRangeMenuGap),
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(AppColors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius))),
      ),
      menuChildren: [
        DateRangePanel(
          initialRange: widget.range,
          today: DateTime.now(),
          onApply: _apply,
          onCancel: _menuController.close,
        ),
      ],
      builder: (context, controller, child) => _button(context, controller.isOpen),
    );
  }

  Widget _button(BuildContext context, bool isOpen) {
    return Tooltip(
      message: 'date_range.tooltip'.tr,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          side: BorderSide(color: isOpen ? AppColors.primary : AppColors.inputBorder),
        ),
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: SizedBox(
            height: AppSizes.buttonHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMedium),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: AppSizes.iconSmall),
                  const SizedBox(width: AppSizes.spaceSmall),
                  Text(DateUtil.rangeLabel(widget.range), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(width: AppSizes.spaceXSmall),
                  Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

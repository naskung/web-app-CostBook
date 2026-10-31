import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class AppDataColumn {
  const AppDataColumn({required this.label, this.flex = 1, this.alignEnd = false});

  final String label;
  final int flex;
  final bool alignEnd;
}

class AppDataTable extends StatelessWidget {
  const AppDataTable({super.key, required this.columns, required this.rows, this.onRowTap});

  final List<AppDataColumn> columns;
  final List<List<Widget>> rows;
  final ValueChanged<int>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: isMobile ? _cardRows(context) : _tableRows(context),
      ),
    );
  }

  List<Widget> _tableRows(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary);
    return [
      _line(context, [for (final column in columns) Text(column.label, style: headerStyle)], isHeader: true),
      for (var index = 0; index < rows.length; index++) ...[
        const Divider(height: 1),
        _tappable(index, _line(context, rows[index])),
      ],
    ];
  }

  Widget _line(BuildContext context, List<Widget> cells, {bool isHeader = false}) {
    return Container(
      color: isHeader ? AppColors.inputFill : null,
      constraints: const BoxConstraints(minHeight: AppSizes.tableRowMinHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMedium, vertical: AppSizes.spaceSmall),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: columns[i].flex,
              child: Align(
                alignment: columns[i].alignEnd ? Alignment.centerRight : Alignment.centerLeft,
                child: i < cells.length ? cells[i] : const SizedBox(),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _cardRows(BuildContext context) {
    return [
      for (var index = 0; index < rows.length; index++) ...[
        if (index > 0) const Divider(height: 1),
        _tappable(index, _card(context, rows[index])),
      ],
    ];
  }

  Widget _card(BuildContext context, List<Widget> cells) {
    final labelStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < columns.length && i < cells.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
              child: Row(
                children: [
                  if (columns[i].label.isNotEmpty) Text(columns[i].label, style: labelStyle),
                  const SizedBox(width: AppSizes.spaceMedium),
                  Expanded(child: Align(alignment: Alignment.centerRight, child: cells[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _tappable(int index, Widget child) {
    final onTap = onRowTap;
    if (onTap == null) return child;
    return InkWell(onTap: () => onTap(index), child: child);
  }
}

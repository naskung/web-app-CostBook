import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/responsive_util.dart';

// เรียงการ์ดเป็นแถว จำนวนคอลัมน์ตามความกว้าง (เกลี่ยแถวให้เท่ากัน) — การ์ดในแถวเดียวกันสูงเท่าการ์ดที่สูงที่สุดในแถว
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.children, this.maxColumns = 3, this.minCardWidth = AppSizes.statCardWidth});

  final List<Widget> children;
  final int maxColumns;
  final double minCardWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = ResponsiveUtil.gridColumns(
            width: constraints.maxWidth,
            minItemWidth: minCardWidth,
            maxColumns: maxColumns,
            count: children.length,
          );
          return Column(
            children: [
              for (var start = 0; start < children.length; start += columns) ...[
                if (start > 0) const SizedBox(height: AppSizes.spaceMedium),
                IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: _rowCells(start, columns)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // แถวสุดท้ายที่การ์ดไม่ครบ เติมช่องว่าง → การ์ดกว้างเท่ากันทุกแถว
  List<Widget> _rowCells(int start, int columns) {
    return [
      for (var column = 0; column < columns; column++) ...[
        if (column > 0) const SizedBox(width: AppSizes.spaceMedium),
        Expanded(child: start + column < children.length ? children[start + column] : const SizedBox()),
      ],
    ];
  }
}

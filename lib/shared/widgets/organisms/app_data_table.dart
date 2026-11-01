import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class AppDataColumn {
  const AppDataColumn({
    required this.label,
    this.flex = 1,
    this.alignEnd = false,
    this.width,
    this.minWidth = AppSizes.tableColumnMinWidth,
  });

  final String label;
  final int flex;
  final bool alignEnd;

  // กว้างตายตัว (เช่น คอลัมน์ปุ่ม) — ไม่ใส่ = ยืดตาม flex
  final double? width;

  // แคบสุดที่ยอมได้ — รวมทุกคอลัมน์แล้วกว้างกว่าที่มี → ตารางเลื่อนซ้าย-ขวาแทนการบีบจนตัวหนังสือตกบรรทัด
  final double minWidth;
}

class AppDataTable extends StatelessWidget {
  const AppDataTable({super.key, required this.columns, required this.rows, this.onRowTap, this.header});

  final List<AppDataColumn> columns;
  final List<List<Widget>> rows;
  final ValueChanged<int>? onRowTap;

  // ส่วนบนสุดในการ์ด เหนือหัวตาราง เช่น แท็บ (AppTabs)
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
    final top = header;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [if (top != null) top, if (isMobile) ..._cardRows(context) else _table(context)],
      ),
    );
  }

  Widget _table(BuildContext context) {
    final table = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _tableRows(context));
    final minWidth = _minWidth();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= minWidth) return table;
        return _HorizontalScroll(child: SizedBox(width: minWidth, child: table));
      },
    );
  }

  // ขอบซ้าย-ขวา + ช่องว่างระหว่างคอลัมน์ + ความกว้างแคบสุดของทุกคอลัมน์ (ต้องตรงกับ _line)
  double _minWidth() {
    var total = AppSizes.spaceMedium * 2 + AppSizes.spaceMedium * (columns.length - 1);
    for (final column in columns) {
      total += column.width ?? column.minWidth;
    }
    return total;
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
          for (var i = 0; i < columns.length; i++) ...[
            // เว้นช่องระหว่างคอลัมน์ ไม่ให้คอลัมน์ชิดขวา (เช่น จำนวน) ติดกับคอลัมน์ถัดไป
            if (i > 0) const SizedBox(width: AppSizes.spaceMedium),
            _cell(columns[i], i < cells.length ? cells[i] : const SizedBox()),
          ],
        ],
      ),
    );
  }

  Widget _cell(AppDataColumn column, Widget child) {
    final aligned = Align(alignment: column.alignEnd ? Alignment.centerRight : Alignment.centerLeft, child: child);
    final width = column.width;
    if (width != null) return SizedBox(width: width, child: aligned);
    return Expanded(flex: column.flex, child: aligned);
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

// เลื่อนซ้าย-ขวา + แถบเลื่อนให้เห็นตลอด (เมาส์ลากแถบได้ / trackpad ปัดได้)
class _HorizontalScroll extends StatefulWidget {
  const _HorizontalScroll({required this.child});

  final Widget child;

  @override
  State<_HorizontalScroll> createState() => _HorizontalScrollState();
}

class _HorizontalScrollState extends State<_HorizontalScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
          child: widget.child,
        ),
      ),
    );
  }
}

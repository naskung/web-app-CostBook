import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/chart_util.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';
import 'package:costbook/shared/widgets/molecules/chart_legend.dart';

class SalesTrendChart extends StatelessWidget {
  const SalesTrendChart({
    super.key,
    required this.days,
    required this.previousDays,
    required this.lastDay,
    required this.currentLabel,
    required this.previousLabel,
  });

  final List<DailySalesModel> days;
  final List<DailySalesModel> previousDays;
  final int lastDay;
  final String currentLabel;
  final String previousLabel;

  @override
  Widget build(BuildContext context) {
    final current = ChartUtil.cumulative(days.take(lastDay).map((day) => day.netSales));
    final previous = ChartUtil.cumulative(previousDays.map((day) => day.netSales));
    final range = ChartUtil.range([...current, ...previous]);
    final dayCount = math.max(days.length, previousDays.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChartLegend(
          items: [
            ChartLegendItem(label: currentLabel, color: AppColors.chartIncome),
            ChartLegendItem(label: previousLabel, color: AppColors.chartMuted),
          ],
        ),
        const SizedBox(height: AppSizes.spaceSmall),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: math.max(dayCount - 1, 1).toDouble(),
              minY: 0,
              maxY: range.max,
              lineBarsData: [_previousLine(previous), _currentLine(current)],
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: range.step,
                getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.chartGrid, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: _titles(context, range),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => AppColors.tooltip,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  maxContentWidth: 220,
                  getTooltipItems: (spots) => [for (final spot in spots) _tooltipItem(context, spot)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _spots(List<double> values) {
    return [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];
  }

  LineChartBarData _currentLine(List<double> values) {
    return LineChartBarData(
      spots: _spots(values),
      color: AppColors.chartIncome,
      barWidth: AppSizes.chartLineWidth,
      isStrokeCapRound: true,
      isStrokeJoinRound: true,
      // จุดที่วันล่าสุด: เห็นยอดวันนี้ แม้ต้นเดือนมีข้อมูลแค่วันเดียว (เส้นยังไม่เกิด)
      dotData: FlDotData(
        checkToShowDot: (spot, bar) => spot.x == bar.spots.last.x,
        getDotPainter:
            (spot, percent, bar, index) => FlDotCirclePainter(
              radius: AppSizes.chartDotRadius,
              color: AppColors.chartIncome,
              strokeWidth: AppSizes.chartLineWidth,
              strokeColor: AppColors.surface,
            ),
      ),
      belowBarData: BarAreaData(show: true, color: AppColors.chartIncome.withValues(alpha: 0.1)),
    );
  }

  LineChartBarData _previousLine(List<double> values) {
    return LineChartBarData(
      spots: _spots(values),
      color: AppColors.chartMuted,
      barWidth: AppSizes.chartLineWidth,
      dashArray: const [6, 4],
      dotData: const FlDotData(show: false),
    );
  }

  LineTooltipItem _tooltipItem(BuildContext context, LineBarSpot spot) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onTooltip) ?? const TextStyle();
    final lineDays = spot.barIndex == 1 ? days : previousDays;
    return LineTooltipItem(
      '${_dateLabel(lineDays, spot.x.toInt())} ${MoneyUtil.format(spot.y)}',
      style,
      textAlign: TextAlign.left,
    );
  }

  String _dateLabel(List<DailySalesModel> lineDays, int index) {
    if (index >= lineDays.length) return '';
    return DateUtil.shortDateLabel(DateUtil.fromApiDate(lineDays[index].date));
  }

  FlTitlesData _titles(BuildContext context, ChartRange range) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    final labelStep = ChartUtil.dayLabelStep(math.max(days.length, previousDays.length));
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: range.step,
          reservedSize: AppSizes.chartAxisReserved,
          getTitlesWidget:
              (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(ChartUtil.axisLabel(value, range), style: style, maxLines: 1, softWrap: false),
              ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: AppSizes.chartBottomReserved,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            final isShown = index % labelStep == 0;
            return SideTitleWidget(meta: meta, child: Text(isShown ? _dateLabel(days, index) : '', style: style));
          },
        ),
      ),
    );
  }
}

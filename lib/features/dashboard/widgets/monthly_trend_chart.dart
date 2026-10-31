import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/chart_util.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';
import 'package:costbook/shared/widgets/molecules/chart_legend.dart';

class TrendSeries {
  const TrendSeries({required this.label, required this.color, required this.valueOf});

  final String label;
  final Color color;
  final double Function(MonthTotalsModel month) valueOf;
}

class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({super.key, required this.months, required this.series});

  final List<MonthTotalsModel> months;
  final List<TrendSeries> series;

  @override
  Widget build(BuildContext context) {
    final values = [for (final line in series) ...months.map(line.valueOf)];
    final range = ChartUtil.range(values);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChartLegend(items: [for (final line in series) ChartLegendItem(label: line.label, color: line.color)]),
        const SizedBox(height: AppSizes.spaceMedium),
        SizedBox(
          height: AppSizes.chartHeight,
          child: LineChart(
            LineChartData(
              minY: range.min,
              maxY: range.max,
              minX: 0,
              maxX: (months.length - 1).toDouble(),
              lineBarsData: [for (final line in series) _line(line)],
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: range.step,
                getDrawingHorizontalLine:
                    (value) => FlLine(color: value == 0 ? AppColors.inputBorder : AppColors.chartGrid, strokeWidth: 1),
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

  LineChartBarData _line(TrendSeries line) {
    return LineChartBarData(
      spots: [for (var i = 0; i < months.length; i++) FlSpot(i.toDouble(), line.valueOf(months[i]))],
      color: line.color,
      barWidth: AppSizes.chartLineWidth,
      isStrokeCapRound: true,
      isStrokeJoinRound: true,
      dotData: FlDotData(
        getDotPainter:
            (spot, percent, bar, index) => FlDotCirclePainter(
              radius: AppSizes.chartDotRadius,
              color: line.color,
              strokeWidth: AppSizes.chartLineWidth,
              strokeColor: AppColors.surface,
            ),
      ),
    );
  }

  LineTooltipItem _tooltipItem(BuildContext context, LineBarSpot spot) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onTooltip) ?? const TextStyle();
    final line = series[spot.barIndex];
    final month = months[spot.x.toInt()].monthDate;
    final header = spot.barIndex == 0 && month != null ? '${DateUtil.monthLabel(month)}\n' : '';
    return LineTooltipItem('$header${line.label} ${MoneyUtil.format(spot.y)}', style, textAlign: TextAlign.left);
  }

  FlTitlesData _titles(BuildContext context, ChartRange range) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
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
            final month = index >= 0 && index < months.length ? months[index].monthDate : null;
            final label = month == null ? '' : DateUtil.shortMonthLabel(month);
            return SideTitleWidget(meta: meta, child: Text(label, style: style));
          },
        ),
      ),
    );
  }
}

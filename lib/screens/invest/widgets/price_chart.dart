import 'package:deuro_wallet/models/price_point.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceChart extends StatelessWidget {
  const PriceChart(
      {super.key, required this.prices, this.startDate = 1742428800});

  final List<PricePoint> prices;
  final int startDate;

  LineChartData get data => LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                Colors.blueGrey.withValues(alpha: 0.8),
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.transparent),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: [lineChartBarData],
        minX: 1742428800000,
        maxX: 1761523200000,
        maxY: 1,
        minY: 0,
      );

  LineChartBarData get lineChartBarData => LineChartBarData(
        isCurved: true,
        color: Colors.white,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [Colors.white.withAlpha(180), Colors.white.withAlpha(1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        spots: prices
            .map((priceSpot) => FlSpot(
                  priceSpot.time.millisecondsSinceEpoch.toDouble(),
                  double.parse(formatFixed(priceSpot.price, 18)),
                ))
            .toList(),
      );

  @override
  Widget build(BuildContext context) => LineChart(data);
}

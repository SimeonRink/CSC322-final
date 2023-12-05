import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  LineChartWidget({
    super.key,
    required this.stockClosePrices,
    required this.maxY,
    required this.minY,
  });

  final List<dynamic> stockClosePrices;
  final double maxY;
  final double minY;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(
                    width: 1,
                  ),
                  left: BorderSide(
                    width: 1,
                  ),
                ),
              ),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              minX: 1.0,
              maxX: stockClosePrices.length.toDouble() + 1,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < stockClosePrices.length; i++)
                      FlSpot(i.toDouble() + 1,
                          (stockClosePrices[i] as num).toDouble()),
                  ],
                  isCurved: true,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

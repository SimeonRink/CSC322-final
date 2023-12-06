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
      body: Center(
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
              show: false,
            ),
            minX: 1.0,
            maxX: stockClosePrices.length.toDouble() + 1,
            minY: minY - 5,
            maxY: maxY + 5,
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
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  BarChartWidget({
    super.key,
    required this.initialFunds,
    required this.currentFunds,
  });

  final double initialFunds;
  final double currentFunds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(
                x: 0,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: initialFunds,
                    color: Colors.blue,
                    width: 16,
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 1,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: currentFunds,
                    color: Colors.green,
                    width: 16,
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

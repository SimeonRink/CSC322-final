import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  BarChartWidget({
    Key? key,
    required this.initialFunds,
    required this.currentFunds,
  }) : super(key: key);

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
              bottomTitles: AxisTitles(
                axisNameWidget: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        'Initial Funds',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        'Current Funds',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

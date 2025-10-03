import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              titlesData: const FlTitlesData(show: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  spots: const [
                    FlSpot(0, 0), FlSpot(1, .8), FlSpot(2, 1.6),
                    FlSpot(3, 1.2), FlSpot(4, 1.9), FlSpot(5, 1.1),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

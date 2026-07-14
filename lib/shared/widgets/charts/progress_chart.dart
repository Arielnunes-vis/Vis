import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Gráfico de linha reutilizável (peso, carga, volume) — fl_chart.
///
/// Componente de apresentação: recebe pontos já calculados. A lógica
/// de agregação fica nos services/controllers de cada feature.
class ProgressChart extends StatelessWidget {
  const ProgressChart({
    required this.points,
    this.color = AppColors.primary,
    this.height = 180,
    super.key,
  });

  /// Pares (x, y). x normalmente é o índice temporal.
  final List<({double x, double y})> points;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(height: height);
    }
    final spots = points.map((p) => FlSpot(p.x, p.y)).toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

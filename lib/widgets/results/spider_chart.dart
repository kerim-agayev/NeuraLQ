import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SpiderChart extends StatelessWidget {
  final double spatialPct;
  final double logicPct;
  final double? verbalPct;
  final double memoryPct;
  final double speedPct;

  const SpiderChart({
    super.key,
    required this.spatialPct,
    required this.logicPct,
    this.verbalPct,
    required this.memoryPct,
    required this.speedPct,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    final titles = ['Spatial', 'Logic', 'Verbal', 'Memory', 'Speed'];
    final values = [
      spatialPct,
      logicPct,
      verbalPct ?? 0,
      memoryPct,
      speedPct,
    ];

    return SizedBox(
      height: 240,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              dataEntries: values
                  .map((v) => RadarEntry(value: v.clamp(0, 100)))
                  .toList(),
              fillColor: primaryColor.withValues(alpha: 0.2),
              borderColor: primaryColor,
              borderWidth: 2,
              entryRadius: 4,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(color: borderColor, width: 0.5),
          tickBorderData: BorderSide(color: borderColor, width: 0.5),
          gridBorderData: BorderSide(color: borderColor, width: 0.5),
          tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
          getTitle: (index, angle) {
            final label = titles[index];
            if (index == 2 && verbalPct == null) {
              return RadarChartTitle(text: '$label\n(N/A)');
            }
            return RadarChartTitle(text: label);
          },
        ),
      ),
    );
  }
}

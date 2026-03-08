import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CategoryBreakdown extends StatelessWidget {
  final double spatialPct;
  final double logicPct;
  final double? verbalPct;
  final double memoryPct;
  final double speedPct;

  const CategoryBreakdown({
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
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final secondaryColor =
        isDark ? CyberpunkColors.secondary : CleanColors.secondary;
    final accentColor =
        isDark ? CyberpunkColors.accent : CleanColors.accent;
    final warningColor =
        isDark ? CyberpunkColors.warning : CleanColors.warning;
    final successColor =
        isDark ? CyberpunkColors.success : CleanColors.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          _Bar(
            label: '\u{1F4D0} Spatial',
            pct: spatialPct,
            color: primaryColor,
            textColor: textSecondary,
            bgColor: borderColor,
          ),
          const SizedBox(height: 10),
          _Bar(
            label: '\u{1F9E9} Logic',
            pct: logicPct,
            color: secondaryColor,
            textColor: textSecondary,
            bgColor: borderColor,
          ),
          const SizedBox(height: 10),
          _Bar(
            label: '\u{1F4DD} Verbal',
            pct: verbalPct,
            color: accentColor,
            textColor: textSecondary,
            bgColor: borderColor,
          ),
          const SizedBox(height: 10),
          _Bar(
            label: '\u{1F9E0} Memory',
            pct: memoryPct,
            color: warningColor,
            textColor: textSecondary,
            bgColor: borderColor,
          ),
          const SizedBox(height: 10),
          _Bar(
            label: '\u{26A1} Speed',
            pct: speedPct,
            color: successColor,
            textColor: textSecondary,
            bgColor: borderColor,
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double? pct;
  final Color color;
  final Color textColor;
  final Color bgColor;

  const _Bar({
    required this.label,
    required this.pct,
    required this.color,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isNA = pct == null;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: AutoSizeText(
            label,
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: isNA
                ? null
                : FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (pct! / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            isNA ? 'N/A' : '${pct!.toInt()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isNA ? textColor.withValues(alpha: 0.5) : textColor,
            ),
          ),
        ),
      ],
    );
  }
}

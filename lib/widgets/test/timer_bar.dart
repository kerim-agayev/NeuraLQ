import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TimerBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0 (remaining fraction)

  const TimerBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? CyberpunkColors.border : CleanColors.border;

    // Color: green(100-60%) → yellow(60-30%) → orange(30-10%) → red(10-0%)
    final Color barColor;
    if (progress > 0.6) {
      barColor = isDark ? CyberpunkColors.success : CleanColors.success;
    } else if (progress > 0.3) {
      barColor = isDark ? CyberpunkColors.warning : CleanColors.warning;
    } else if (progress > 0.1) {
      barColor = const Color(0xFFFF8C00); // orange
    } else {
      barColor = isDark ? CyberpunkColors.error : CleanColors.error;
    }

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(3),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

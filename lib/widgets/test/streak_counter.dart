import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak < 2) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warningColor =
        isDark ? CyberpunkColors.warning : CleanColors.warning;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: warningColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: warningColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{1F525}', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                '$streak',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: warningColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

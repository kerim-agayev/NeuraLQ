import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AnswerFeedback extends StatelessWidget {
  final bool isCorrect;

  const AnswerFeedback({super.key, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isCorrect
        ? (isDark ? CyberpunkColors.success : CleanColors.success)
        : (isDark ? CyberpunkColors.error : CleanColors.error);

    return ClipRect(
      child: Container(
        color: color.withValues(alpha: 0.15),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCorrect ? '\u{2705}' : '\u{274C}',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCorrect ? 'Correct!' : 'Wrong!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

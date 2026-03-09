import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ProgressIndicatorBar extends StatelessWidget {
  final int current;
  final int total;

  const ProgressIndicatorBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final bgColor = isDark ? CyberpunkColors.border : CleanColors.border;
    final progress = total > 0 ? current / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AutoSizeText(
              'test.questionOf'.tr(args: ['$current', '$total']),
              maxLines: 1,
              minFontSize: 10,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            AutoSizeText(
              '${(progress * 100).toInt()}%',
              maxLines: 1,
              minFontSize: 10,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

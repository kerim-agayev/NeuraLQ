import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../constants/celebrities.dart';

class CelebrityMatchCard extends StatelessWidget {
  final String celebrityKey;

  const CelebrityMatchCard({super.key, required this.celebrityKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    final celebrity = getCelebrityByKey(celebrityKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            'result.celebrityMatch'.tr(),
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 10),
          Text(celebrity.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 10),
          AutoSizeText(
            celebrity.label,
            maxLines: 1,
            minFontSize: 16,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'result.iqRange'.tr(args: ['${celebrity.minIq}', '${celebrity.maxIq}']),
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

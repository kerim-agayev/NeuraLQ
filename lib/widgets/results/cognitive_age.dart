import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CognitiveAgeCard extends StatelessWidget {
  final int cognitiveAge;
  final int? globalRank;
  final int? countryRank;

  const CognitiveAgeCard({
    super.key,
    required this.cognitiveAge,
    this.globalRank,
    this.countryRank,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            emoji: '\u{1F9D1}',
            value: '$cognitiveAge',
            label: 'result.cognitiveAge'.tr(),
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textColor: textColor,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            emoji: '\u{1F30D}',
            value: globalRank != null ? '#$globalRank' : '—',
            label: 'result.globalRank'.tr(),
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textColor: textColor,
            textSecondary: textSecondary,
          ),
        ),
        if (countryRank != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _InfoTile(
              emoji: '\u{1F3C5}',
              value: '#$countryRank',
              label: 'result.countryRank'.tr(),
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              textSecondary: textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color textSecondary;

  const _InfoTile({
    required this.emoji,
    required this.value,
    required this.label,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          AutoSizeText(
            value,
            maxLines: 1,
            minFontSize: 14,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          AutoSizeText(
            label,
            maxLines: 1,
            minFontSize: 8,
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

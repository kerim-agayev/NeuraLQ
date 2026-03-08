import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/ui/skeleton_loader.dart';

class StatsRow extends StatelessWidget {
  final int? neuralCoins;
  final int? brainPoints;
  final int? currentStreak;
  final bool isLoading;

  const StatsRow({
    super.key,
    this.neuralCoins,
    this.brainPoints,
    this.currentStreak,
    this.isLoading = false,
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
        _StatCard(
          emoji: '\u{1F4B0}',
          label: 'stats.nc'.tr(),
          value: neuralCoins?.toString() ?? '0',
          isLoading: isLoading,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          textSecondary: textSecondary,
        ),
        const SizedBox(width: 8),
        _StatCard(
          emoji: '\u{1F9E0}',
          label: 'stats.bp'.tr(),
          value: brainPoints?.toString() ?? '0',
          isLoading: isLoading,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          textSecondary: textSecondary,
        ),
        const SizedBox(width: 8),
        _StatCard(
          emoji: '\u{1F525}',
          label: 'stats.streak'.tr(),
          value: currentStreak?.toString() ?? '0',
          isLoading: isLoading,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          textSecondary: textSecondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool isLoading;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color textSecondary;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isLoading,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: isLoading
            ? const Column(
                children: [
                  SkeletonLoader(height: 20, width: 20),
                  SizedBox(height: 6),
                  SkeletonLoader(height: 12, width: 40),
                ],
              )
            : Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    value,
                    maxLines: 1,
                    minFontSize: 12,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  AutoSizeText(
                    label,
                    maxLines: 1,
                    minFontSize: 8,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

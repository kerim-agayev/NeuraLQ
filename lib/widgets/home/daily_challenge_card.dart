import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/ui/skeleton_loader.dart';

class DailyChallengeCard extends StatelessWidget {
  final bool isLoading;
  final bool alreadyDone;
  final bool noChallenge;
  final VoidCallback onTap;

  const DailyChallengeCard({
    super.key,
    this.isLoading = false,
    this.alreadyDone = false,
    this.noChallenge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final warningColor =
        isDark ? CyberpunkColors.warning : CleanColors.warning;
    final successColor =
        isDark ? CyberpunkColors.success : CleanColors.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: noChallenge
                ? textSecondary.withValues(alpha: 0.3)
                : alreadyDone
                    ? successColor.withValues(alpha: 0.5)
                    : warningColor.withValues(alpha: 0.5),
          ),
        ),
        child: isLoading
            ? const Row(
                children: [
                  SkeletonLoader(height: 40, width: 40, borderRadius: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(height: 16, width: 120),
                        SizedBox(height: 6),
                        SkeletonLoader(height: 12, width: 180),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: noChallenge
                          ? textSecondary.withValues(alpha: 0.1)
                          : (alreadyDone ? successColor : warningColor)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        noChallenge
                            ? '\u{1F4A4}'
                            : alreadyDone
                                ? '\u{2705}'
                                : '\u{26A1}',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'daily.title'.tr(),
                          maxLines: 1,
                          minFontSize: 13,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AutoSizeText(
                          noChallenge
                              ? 'daily.noChallenge'.tr()
                              : alreadyDone
                                  ? 'daily.completed'.tr()
                                  : 'daily.testBrainDaily'.tr(),
                          maxLines: 1,
                          minFontSize: 10,
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: textSecondary,
                    size: 24,
                  ),
                ],
              ),
      ),
    );
  }
}

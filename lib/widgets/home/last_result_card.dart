import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../constants/celebrities.dart';
import '../../models/result.dart';
import '../../widgets/ui/skeleton_loader.dart';

class LastResultCard extends StatelessWidget {
  final TestHistoryItem? lastResult;
  final bool isLoading;
  final VoidCallback? onTap;

  const LastResultCard({
    super.key,
    this.lastResult,
    this.isLoading = false,
    this.onTap,
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
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;

    if (!isLoading && lastResult == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
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
                        SkeletonLoader(height: 16, width: 100),
                        SizedBox(height: 6),
                        SkeletonLoader(height: 12, width: 150),
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
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: AutoSizeText(
                        '${lastResult!.iqScore}',
                        maxLines: 1,
                        minFontSize: 12,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'Last Result',
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
                          'IQ ${lastResult!.iqScore} • ${getCelebrityByKey(lastResult!.celebrityMatch).label}',
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

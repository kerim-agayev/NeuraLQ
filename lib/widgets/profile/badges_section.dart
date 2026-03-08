import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Badge;
import '../../config/theme.dart';
import '../../constants/badges.dart';
import '../../models/user.dart';

class BadgesSection extends StatelessWidget {
  final List<Badge> earnedBadges;

  const BadgesSection({super.key, required this.earnedBadges});

  @override
  Widget build(BuildContext context) {
    final earnedKeys = earnedBadges.map((b) => b.name).toSet();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: allBadges.length,
      itemBuilder: (context, index) {
        final badge = allBadges[index];
        final isEarned = earnedKeys.contains(badge.key);
        return _BadgeCell(badge: badge, isEarned: isEarned);
      },
    );
  }
}

class _BadgeCell extends StatelessWidget {
  final BadgeInfo badge;
  final bool isEarned;

  const _BadgeCell({required this.badge, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    return Opacity(
      opacity: isEarned ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned ? primaryColor : borderColor,
            width: isEarned ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(badge.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 2),
                  AutoSizeText(
                    badge.title,
                    maxLines: 2,
                    minFontSize: 8,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isEarned ? FontWeight.w600 : FontWeight.normal,
                      color: isEarned ? textColor : textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isEarned)
              Positioned(
                right: 2,
                bottom: 2,
                child: Icon(Icons.lock_rounded,
                    size: 14, color: textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Badge;
import '../../config/theme.dart';
import '../../constants/badges.dart';
import '../../models/user.dart';

void showBadgeUnlockModal(BuildContext context, List<Badge> badges) {
  if (badges.isEmpty) return;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? CyberpunkColors.surface : CleanColors.surface;
  final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
  final primaryColor = isDark ? CyberpunkColors.primary : CleanColors.primary;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            const Text('\u{1F3C6}', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              badges.length == 1
                  ? 'badges.unlocked'.tr()
                  : 'badges.unlockedMultiple'.tr(args: ['${badges.length}']),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: badges.map((badge) {
            final info = getBadgeInfo(badge.name);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(info.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          info.description,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('badges.awesome'.tr(),
                style: TextStyle(color: primaryColor, fontSize: 16)),
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';

class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? CyberpunkColors.surfaceLight.withValues(alpha: 0.6)
          : CleanColors.surfaceLight,
      highlightColor: isDark
          ? CyberpunkColors.border.withValues(alpha: 0.8)
          : CleanColors.border,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? CyberpunkColors.surface : CleanColors.surfaceLight,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

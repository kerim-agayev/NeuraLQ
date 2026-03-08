import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../constants/badges.dart';
import '../../providers/test_provider.dart';
import '../../widgets/results/iq_reveal.dart';
import '../../widgets/results/spider_chart.dart';
import '../../widgets/results/celebrity_match.dart';
import '../../widgets/results/cognitive_age.dart';
import '../../widgets/results/category_breakdown.dart';
import '../../widgets/results/share_card.dart';
import '../../widgets/ui/brain_loader.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _badgeShown = false;

  @override
  void initState() {
    super.initState();
    // Show badge modal after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBadgeModalIfNeeded();
    });
  }

  void _showBadgeModalIfNeeded() {
    if (_badgeShown) return;
    final result = ref.read(testProvider).result;
    if (result == null || result.newBadges.isEmpty) return;

    _badgeShown = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgColor =
            isDark ? CyberpunkColors.surface : CleanColors.surface;
        final textColor =
            isDark ? CyberpunkColors.text : CleanColors.text;
        final primaryColor =
            isDark ? CyberpunkColors.primary : CleanColors.primary;

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
                result.newBadges.length == 1
                    ? 'New Badge Unlocked!'
                    : '${result.newBadges.length} Badges Unlocked!',
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
            children: result.newBadges.map((badge) {
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
              child: Text('Awesome!',
                  style: TextStyle(color: primaryColor, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _goHome() {
    ref.read(testProvider.notifier).reset();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;

    final result = ref.watch(testProvider).result;

    if (result == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const BrainLoader(message: 'Loading results...'),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              children: [
                // Title
                Text(
                  'Test Complete!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                // IQ Reveal with count-up animation
                IqReveal(targetIq: result.iqScore),
                const SizedBox(height: 28),

                // Spider Chart (fl_chart RadarChart)
                SpiderChart(
                  spatialPct: result.spatialPercentile,
                  logicPct: result.logicPercentile,
                  verbalPct: result.verbalPercentile,
                  memoryPct: result.memoryPercentile,
                  speedPct: result.speedPercentile,
                ),
                const SizedBox(height: 24),

                // Celebrity Match
                CelebrityMatchCard(celebrityKey: result.celebrityMatch),
                const SizedBox(height: 16),

                // Cognitive Age + Ranks
                CognitiveAgeCard(
                  cognitiveAge: result.cognitiveAge,
                  globalRank: result.globalRank,
                  countryRank: result.countryRank,
                ),
                const SizedBox(height: 16),

                // Category Breakdown with N/A support
                CategoryBreakdown(
                  spatialPct: result.spatialPercentile,
                  logicPct: result.logicPercentile,
                  verbalPct: result.verbalPercentile,
                  memoryPct: result.memoryPercentile,
                  speedPct: result.speedPercentile,
                ),
                const SizedBox(height: 24),

                // Share + Certificate + Take Another
                ShareCard(
                  iqScore: result.iqScore,
                  celebrityKey: result.celebrityMatch,
                  certificateUrl: result.certificateUrl,
                  onGoHome: _goHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

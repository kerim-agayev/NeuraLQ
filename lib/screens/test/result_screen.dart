import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/test_provider.dart';
import '../../widgets/ui/badge_unlock_modal.dart';
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
    showBadgeUnlockModal(context, result.newBadges);
  }

  void _goHome() {
    ref.read(testProvider.notifier).reset();
    ref.read(authProvider.notifier).refreshUser();
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
        body: BrainLoader(message: 'result.loadingResult'.tr()),
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
                  'result.testComplete'.tr(),
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
                  speedPct: result.speedPercentile,
                ),
                const SizedBox(height: 24),

                // Share + Certificate + Take Another
                ShareCard(
                  iqScore: result.iqScore,
                  celebrityKey: result.celebrityMatch,
                  certificateUrl: result.certificateUrl,
                  onGoHome: _goHome,
                  result: result,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

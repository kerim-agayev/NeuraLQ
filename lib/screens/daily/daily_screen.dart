import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/daily_provider.dart';
import '../../widgets/test/question_options.dart';
import '../../widgets/test/timer_bar.dart';
import '../../widgets/ui/badge_unlock_modal.dart';
import '../../widgets/ui/brain_loader.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  Timer? _timer;
  int _elapsedMs = 0;
  int _timeLimit = 30;
  bool _isSubmitting = false;
  int? _selectedAnswer;
  bool _showFeedback = false;
  int? _correctAnswer;
  bool _badgeShown = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dailyProvider.notifier).loadToday());
  }

  void _startTimer() {
    final challenge = ref.read(dailyProvider).challenge;
    if (challenge == null) return;

    _timeLimit = challenge.question.timeLimit;
    _elapsedMs = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedMs += 100;
      });
      if (_elapsedMs >= _timeLimit * 1000) {
        timer.cancel();
        _submitAnswer(null);
      }
    });
  }

  double get _timerProgress {
    if (_timeLimit <= 0) return 1.0;
    return 1.0 - (_elapsedMs / (_timeLimit * 1000)).clamp(0.0, 1.0);
  }

  Future<void> _submitAnswer(int? selectedAnswer) async {
    if (_isSubmitting || _showFeedback) return;
    _isSubmitting = true;
    _timer?.cancel();

    setState(() {
      _selectedAnswer = selectedAnswer;
    });

    await ref.read(dailyProvider.notifier).submitAttempt(
          selectedAnswer: selectedAnswer ?? 0,
          responseTimeMs: _elapsedMs,
        );

    if (!mounted) return;

    final state = ref.read(dailyProvider);
    if (state.attemptResult != null) {
      setState(() {
        _showFeedback = true;
        _correctAnswer = state.attemptResult!.correctAnswer;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // Show badge modal if new badges earned
      if (!_badgeShown && state.attemptResult!.newBadges.isNotEmpty) {
        _badgeShown = true;
        showBadgeUnlockModal(context, state.attemptResult!.newBadges);
      }
    }

    _isSubmitting = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final successColor =
        isDark ? CyberpunkColors.success : CleanColors.success;
    final errorColor = isDark ? CyberpunkColors.error : CleanColors.error;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final warningColor =
        isDark ? CyberpunkColors.warning : CleanColors.warning;

    final daily = ref.watch(dailyProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'daily.title'.tr(),
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(
          daily: daily,
          isDark: isDark,
          bgColor: bgColor,
          textColor: textColor,
          textSecondary: textSecondary,
          primaryColor: primaryColor,
          successColor: successColor,
          errorColor: errorColor,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          warningColor: warningColor,
        ),
      ),
    );
  }

  Widget _buildBody({
    required DailyState daily,
    required bool isDark,
    required Color bgColor,
    required Color textColor,
    required Color textSecondary,
    required Color primaryColor,
    required Color successColor,
    required Color errorColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color warningColor,
  }) {
    // Error state
    if (daily.error != null &&
        daily.status == DailyChallengeStatus.loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u{26A0}\u{FE0F}', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                daily.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () =>
                    ref.read(dailyProvider.notifier).loadToday(),
                icon: const Icon(Icons.refresh),
                label: Text('common.retry'.tr()),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ],
          ),
        ),
      );
    }

    switch (daily.status) {
      case DailyChallengeStatus.loading:
        return BrainLoader(message: 'daily.loadingDaily'.tr());

      case DailyChallengeStatus.noChallenge:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('\u{1F4AD}', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'daily.noChallenge'.tr(),
                  style: TextStyle(fontSize: 16, color: textSecondary),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('common.goBack'.tr(),
                      style: TextStyle(color: primaryColor)),
                ),
              ],
            ),
          ),
        );

      case DailyChallengeStatus.alreadyDone:
        return _buildAlreadyDone(
          daily: daily,
          textColor: textColor,
          textSecondary: textSecondary,
          primaryColor: primaryColor,
          successColor: successColor,
          errorColor: errorColor,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
        );

      case DailyChallengeStatus.question:
        if (daily.challenge == null) {
          return BrainLoader(message: 'common.loading'.tr());
        }
        // Start timer on first build of question state
        if (_timer == null || !_timer!.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                daily.status == DailyChallengeStatus.question &&
                !_isSubmitting) {
              _startTimer();
            }
          });
        }
        return _buildQuestion(
          daily: daily,
          isDark: isDark,
          textColor: textColor,
          textSecondary: textSecondary,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
        );

      case DailyChallengeStatus.result:
        return _buildResult(
          daily: daily,
          textColor: textColor,
          textSecondary: textSecondary,
          primaryColor: primaryColor,
          successColor: successColor,
          errorColor: errorColor,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          warningColor: warningColor,
        );
    }
  }

  // ── Question State ──
  Widget _buildQuestion({
    required DailyState daily,
    required bool isDark,
    required Color textColor,
    required Color textSecondary,
    required Color primaryColor,
    required Color surfaceColor,
    required Color borderColor,
  }) {
    final challenge = daily.challenge!;
    final question = challenge.question;

    String categoryLabel = question.category;
    switch (question.category.toUpperCase()) {
      case 'SPATIAL':
        categoryLabel = '\u{1F4D0} ${'result.spatial'.tr()}';
      case 'LOGIC':
        categoryLabel = '\u{1F9E9} ${'result.logic'.tr()}';
      case 'SPEED':
        categoryLabel = '\u{26A1} ${'result.speed'.tr()}';
      case 'MEMORY':
        categoryLabel = '\u{1F9E0} ${'result.memory'.tr()}';
    }

    return Column(
      children: [
        // Timer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TimerBar(progress: _timerProgress),
        ),
        const SizedBox(height: 16),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    categoryLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Question text
                AutoSizeText(
                  question.content,
                  maxLines: 4,
                  minFontSize: 14,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.4,
                  ),
                ),

                // Question image
                if (question.imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      question.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => SizedBox(
                        height: 100,
                        child:
                            Center(child: Text('result.failedToLoad'.tr())),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Options
                QuestionOptions(
                  options: question.options,
                  selectedAnswer: _selectedAnswer,
                  correctAnswer: _showFeedback ? _correctAnswer : null,
                  showFeedback: _showFeedback,
                  enabled: !_isSubmitting && !_showFeedback,
                  onSelect: _submitAnswer,
                ),

                // Community stats
                if (challenge.totalAttempts > 0) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'daily.peopleAttempted'.tr(args: ['${challenge.totalAttempts}']),
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Result State ──
  Widget _buildResult({
    required DailyState daily,
    required Color textColor,
    required Color textSecondary,
    required Color primaryColor,
    required Color successColor,
    required Color errorColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color warningColor,
  }) {
    final result = daily.attemptResult!;
    final challenge = daily.challenge;
    final isCorrect = result.isCorrect;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        children: [
          // Result emoji
          Text(
            isCorrect ? '\u{2705}' : '\u{274C}',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 12),
          Text(
            isCorrect ? 'daily.correct'.tr() : 'daily.incorrect'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isCorrect ? successColor : errorColor,
            ),
          ),
          const SizedBox(height: 24),

          // Rewards
          _RewardCard(
            icon: '\u{1F9E0}',
            label: 'daily.pointsEarned'.tr(args: ['${result.brainPointsEarned}']),
            value: '+${result.brainPointsEarned}',
            color: primaryColor,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
          ),
          const SizedBox(height: 8),
          _RewardCard(
            icon: '\u{1FA99}',
            label: 'daily.coinsEarned'.tr(args: ['${result.neuralCoinsEarned}']),
            value: '+${result.neuralCoinsEarned}',
            color: warningColor,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
          ),
          if (result.streakBonus > 0) ...[
            const SizedBox(height: 8),
            _RewardCard(
              icon: '\u{1F381}',
              label: 'daily.streakBonus'.tr(),
              value: '+${result.streakBonus}',
              color: successColor,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
            ),
          ],
          const SizedBox(height: 16),

          // Streak display
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('\u{1F525}',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'daily.streakDays'.tr(args: ['${result.streak}']),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Community stats
          if (challenge != null && challenge.totalAttempts > 0) ...[
            Text(
              'daily.peopleAttempted'.tr(args: ['${challenge.totalAttempts}']),
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            if (challenge.totalAttempts > 0) ...[
              const SizedBox(height: 4),
              Text(
                'daily.gotItRight'.tr(args: ['${((challenge.correctAttempts / challenge.totalAttempts) * 100).round()}']),
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
            ],
          ],
          const SizedBox(height: 24),

          // Go Home button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'result.goHome'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Already Done State ──
  Widget _buildAlreadyDone({
    required DailyState daily,
    required Color textColor,
    required Color textSecondary,
    required Color primaryColor,
    required Color successColor,
    required Color errorColor,
    required Color surfaceColor,
    required Color borderColor,
  }) {
    final challenge = daily.challenge;
    final userAnswer = challenge?.userAnswer;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Column(
        children: [
          const Text('\u{2705}', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            'daily.alreadyDone'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'daily.comeBackTomorrow'.tr(),
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),

          // Previous answer info
          if (userAnswer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userAnswer.isCorrect
                            ? '\u{2705}'
                            : '\u{274C}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userAnswer.isCorrect
                            ? 'daily.answeredCorrectly'.tr()
                            : 'daily.answeredIncorrectly'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: userAnswer.isCorrect
                              ? successColor
                              : errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'daily.brainPointsEarned'.tr(args: ['${userAnswer.brainPointsEarned}']),
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Community stats
          if (challenge != null && challenge.totalAttempts > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Text(
                    'daily.peopleAttempted'.tr(args: ['${challenge.totalAttempts}']),
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                  if (challenge.totalAttempts > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'daily.gotItRight'.tr(args: ['${((challenge.correctAttempts / challenge.totalAttempts) * 100).round()}']),
                      style:
                          TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Go back button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'common.goBack'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reward Card ──
class _RewardCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final Color surfaceColor;
  final Color borderColor;

  const _RewardCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.surfaceColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: AutoSizeText(
              label,
              maxLines: 1,
              minFontSize: 10,
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? CyberpunkColors.text
                        : CleanColors.text,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

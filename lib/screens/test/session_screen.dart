import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/test_provider.dart';
import '../../widgets/test/answer_feedback.dart';
import '../../widgets/test/progress_indicator_bar.dart';
import '../../widgets/test/question_options.dart';
import '../../widgets/test/streak_counter.dart';
import '../../widgets/test/timer_bar.dart';
import '../../widgets/ui/brain_loader.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  Timer? _timer;
  int _elapsedMs = 0;
  int _timeLimit = 30;
  bool _showFeedback = false;
  bool? _lastAnswerCorrect;
  int? _correctAnswer;
  int? _selectedAnswer; // Track locally for immediate UI feedback
  bool _isSubmitting = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final question = ref.read(testProvider).currentQuestion;
    if (question == null) return;

    _timeLimit = question.timeLimit;
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
        _submitAnswer(null); // Time's up
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

    // Immediately highlight the selected option
    setState(() {
      _selectedAnswer = selectedAnswer;
    });

    await ref.read(testProvider.notifier).submitAnswer(
          selectedAnswer: selectedAnswer,
          responseTimeMs: _elapsedMs,
        );

    if (!mounted) return;

    final state = ref.read(testProvider);
    if (state.error != null) {
      Fluttertoast.showToast(
        msg: state.error!,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        _selectedAnswer = null;
      });
      _isSubmitting = false;
      _startTimer();
      return;
    }

    // Get the answer result for the current question
    final question = state.currentQuestion;
    final questionId = question?.id ?? '';
    final isCorrect = state.answerResults[questionId] ?? false;

    setState(() {
      _showFeedback = true;
      _lastAnswerCorrect = isCorrect;
      _correctAnswer = selectedAnswer != null && isCorrect ? selectedAnswer : null;
    });

    // Show feedback for 800ms
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Move to next question
    ref.read(testProvider.notifier).nextQuestion();

    final newState = ref.read(testProvider);
    if (newState.isTestComplete) {
      await _completeTest();
    } else {
      setState(() {
        _showFeedback = false;
        _lastAnswerCorrect = null;
        _correctAnswer = null;
        _selectedAnswer = null;
        _isSubmitting = false;
      });
      _startTimer();
    }
  }

  Future<void> _completeTest() async {
    setState(() => _isCompleting = true);

    try {
      await ref.read(testProvider.notifier).completeTest();
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Failed to load results: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isCompleting = false);
      return;
    }

    if (!mounted) return;

    final state = ref.read(testProvider);
    if (state.error != null) {
      Fluttertoast.showToast(
        msg: state.error!,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isCompleting = false);
      return;
    }

    if (state.result != null) {
      context.go('/test/result');
    } else {
      // Result is null but no error — shouldn't happen, navigate anyway
      Fluttertoast.showToast(
        msg: 'result.failedToLoad'.tr(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isCompleting = false);
    }
  }

  Future<bool> _onWillPop() async {
    _timer?.cancel();
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor =
            isDark ? CyberpunkColors.surface : CleanColors.surface;
        final textColor =
            isDark ? CyberpunkColors.text : CleanColors.text;
        final primaryColor =
            isDark ? CyberpunkColors.primary : CleanColors.primary;
        final errorColor =
            isDark ? CyberpunkColors.error : CleanColors.error;

        return AlertDialog(
          backgroundColor: bgColor,
          title: Text('test.quitTitle'.tr(), style: TextStyle(color: textColor)),
          content: Text(
            'test.quitMessage'.tr(),
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('common.cancel'.tr(), style: TextStyle(color: primaryColor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('test.quit'.tr(), style: TextStyle(color: errorColor)),
            ),
          ],
        );
      },
    );

    if (shouldQuit == true) {
      ref.read(testProvider.notifier).reset();
      if (mounted) context.go('/home');
      return true;
    } else {
      _startTimer();
      return false;
    }
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

    final test = ref.watch(testProvider);
    final question = test.currentQuestion;

    if (_isCompleting) {
      return Scaffold(
        backgroundColor: bgColor,
        body: BrainLoader(message: 'test.submitting'.tr()),
      );
    }

    if (question == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: BrainLoader(message: 'common.loading'.tr()),
      );
    }

    // Category label
    String categoryLabel = question.category;
    switch (question.category.toUpperCase()) {
      case 'SPATIAL':
        categoryLabel = '\u{1F4D0} ${'result.spatial'.tr()}';
      case 'LOGIC':
        categoryLabel = '\u{1F9E9} ${'result.logic'.tr()}';
      case 'VERBAL':
        categoryLabel = '\u{1F4DD} ${'result.verbal'.tr()}';
      case 'MEMORY':
        categoryLabel = '\u{1F9E0} ${'result.memory'.tr()}';
      case 'SPEED':
        categoryLabel = '\u{26A1} ${'result.speed'.tr()}';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: textSecondary),
                          onPressed: _onWillPop,
                        ),
                        Expanded(
                          child: ProgressIndicatorBar(
                            current: test.currentIndex + 1,
                            total: test.totalQuestions,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StreakCounter(streak: test.streak),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Timer bar
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
                              color: (isDark
                                      ? CyberpunkColors.primary
                                      : CleanColors.primary)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              categoryLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? CyberpunkColors.primary
                                    : CleanColors.primary,
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

                          // Question image (max 35% of screen height)
                          if (question.imageUrl != null) ...[
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  question.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const SizedBox(
                                    height: 100,
                                    child: Center(
                                        child: Text('Image failed to load')),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Options
                          QuestionOptions(
                            options: question.options,
                            selectedAnswer: _selectedAnswer,
                            correctAnswer: _correctAnswer,
                            showFeedback: _showFeedback,
                            enabled: !_isSubmitting && !_showFeedback,
                            onSelect: _submitAnswer,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Feedback overlay
              if (_showFeedback && _lastAnswerCorrect != null)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _showFeedback ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnswerFeedback(isCorrect: _lastAnswerCorrect!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

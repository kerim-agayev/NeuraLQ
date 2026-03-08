import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/result.dart';
import '../../providers/auth_provider.dart';
import '../../providers/daily_provider.dart';
import '../../providers/test_provider.dart';
import '../../services/storage_service.dart';
import '../../services/test_service.dart';
import '../../widgets/home/daily_challenge_card.dart';
import '../../widgets/home/last_result_card.dart';
import '../../widgets/home/quick_test_button.dart';
import '../../widgets/home/stats_row.dart';
import '../../widgets/ui/neon_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TestHistoryItem? _lastResult;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ref.read(dailyProvider.notifier).loadToday();
    _loadHistory();
    _checkTestBackup();
  }

  Future<void> _checkTestBackup() async {
    final hasBackup =
        await ref.read(testProvider.notifier).restoreFromBackup();
    if (hasBackup && mounted) {
      _showResumeTestDialog();
    }
  }

  void _showResumeTestDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final errorColor =
        isDark ? CyberpunkColors.error : CleanColors.error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        title: Text('test.incompleteTitle'.tr(),
            style: TextStyle(color: textColor)),
        content: Text(
          'test.incompleteMessage'.tr(),
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ref.read(testProvider.notifier).reset();
              await StorageService.clearTestBackup();
            },
            child: Text('test.discard'.tr(), style: TextStyle(color: errorColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/test/session');
            },
            child: Text('test.resume'.tr(), style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await TestService.getHistory(limit: 1);
      if (mounted) {
        setState(() {
          _lastResult = history.items.isNotEmpty ? history.items.first : null;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _onRefresh() async {
    ref.read(authProvider.notifier).refreshUser();
    ref.read(dailyProvider.notifier).loadToday();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    final auth = ref.watch(authProvider);
    final daily = ref.watch(dailyProvider);
    final user = auth.user;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            NeonText(
              'NeuralQ',
              fontSize: 28,
              color: primaryColor,
              glow: isDark,
            ),
            const SizedBox(height: 4),

            // Welcome message
            AutoSizeText(
              'home.welcome'.tr(args: [user?.username ?? 'Explorer']),
              maxLines: 1,
              minFontSize: 13,
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            StatsRow(
              neuralCoins: user?.neuralCoins,
              brainPoints: user?.brainPoints,
              currentStreak: user?.currentStreak,
              isLoading: auth.isLoading,
            ),
            const SizedBox(height: 20),

            // Quick test button
            QuickTestButton(
              onPressed: () => context.push('/test/select-mode'),
            ),
            const SizedBox(height: 20),

            // Section title
            Text(
              'home.activity'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Daily challenge card
            DailyChallengeCard(
              isLoading: daily.isLoading,
              alreadyDone:
                  daily.status == DailyChallengeStatus.alreadyDone,
              onTap: () => context.push('/daily'),
            ),
            const SizedBox(height: 12),

            // Last result card
            LastResultCard(
              lastResult: _lastResult,
              isLoading: _isLoadingHistory,
              onTap: _lastResult != null
                  ? () => context.push('/history/${_lastResult!.testSessionId}')
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

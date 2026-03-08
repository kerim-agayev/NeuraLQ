import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../constants/celebrities.dart';
import '../../constants/countries.dart';
import '../../constants/languages.dart';
import '../../models/daily.dart';
import '../../models/result.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/daily_service.dart';
import '../../services/test_service.dart';
import '../../widgets/home/stats_row.dart';
import '../../widgets/profile/badges_section.dart';
import '../../widgets/profile/edit_profile_modal.dart';
import '../../widgets/profile/language_picker_modal.dart';
import '../../widgets/ui/skeleton_loader.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  DailyStats? _dailyStats;
  TestHistoryResponse? _historyResponse;
  bool _isLoadingStats = true;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadDailyStats();
    _loadHistory();
  }

  Future<void> _loadDailyStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await DailyService.getStats();
      if (mounted) {
        setState(() {
          _dailyStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final res = await TestService.getHistory(page: 1, limit: 5);
      if (mounted) {
        setState(() {
          _historyResponse = res;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _onRefresh() async {
    ref.read(authProvider.notifier).refreshUser();
    await Future.wait([_loadDailyStats(), _loadHistory()]);
  }

  String _getFlagEmoji(String? code) {
    if (code == null) return '';
    final c = countries.cast<Country?>().firstWhere(
          (c) => c!.code == code,
          orElse: () => null,
        );
    return c?.flag ?? '';
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _formatJoinDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _confirmLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final errorColor =
        isDark ? CyberpunkColors.error : CleanColors.error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        title: Text('Logout?', style: TextStyle(color: textColor)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: TextStyle(color: errorColor)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final errorColor =
        isDark ? CyberpunkColors.error : CleanColors.error;

    final auth = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final user = auth.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayName = user.displayName ?? user.username;
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    final currentLang = appLanguages.cast<AppLanguage?>().firstWhere(
          (l) => l!.code == settings.language,
          orElse: () => appLanguages.first,
        );

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Profile Header ──
            CircleAvatar(
              radius: 36,
              backgroundColor: primaryColor,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(initial,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? CyberpunkColors.background
                            : Colors.white,
                      ))
                  : null,
            ),
            const SizedBox(height: 12),
            AutoSizeText(
              displayName,
              maxLines: 1,
              minFontSize: 14,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (user.displayName != null)
              Text(
                '@${user.username}',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
            Text(
              user.email,
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.country != null)
                    Text(
                      '${_getFlagEmoji(user.country)} ${user.country!}',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  if (user.age != null)
                    Text(
                      '${user.country != null ? '  \u{2022}  ' : ''}Age ${user.age}',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  Text(
                    '${(user.country != null || user.age != null) ? '  \u{2022}  ' : ''}Joined ${_formatJoinDate(user.createdAt)}',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats Row ──
            StatsRow(
              neuralCoins: user.neuralCoins,
              brainPoints: user.brainPoints,
              currentStreak: user.currentStreak,
              isLoading: auth.isLoading,
            ),
            const SizedBox(height: 16),

            // ── Edit Profile ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => EditProfileModal(user: user),
                ),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Badges ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Badges',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            BadgesSection(earnedBadges: user.badges),
            const SizedBox(height: 24),

            // ── Daily Stats ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daily Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildDailyStats(surfaceColor, borderColor, textColor, textSecondary),
            const SizedBox(height: 24),

            // ── Test History ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTestHistory(
                surfaceColor, borderColor, textColor, textSecondary, primaryColor),
            const SizedBox(height: 24),

            // ── Settings ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Theme toggle
                  _SettingsTile(
                    leading: Icon(
                      settings.isCyberpunk
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: primaryColor,
                    ),
                    title: settings.isCyberpunk
                        ? 'Cyberpunk Mode'
                        : 'Clean Mode',
                    titleColor: textColor,
                    trailing: Switch(
                      value: settings.isCyberpunk,
                      onChanged: (_) =>
                          ref.read(settingsProvider.notifier).toggleTheme(),
                      activeTrackColor: primaryColor.withValues(alpha: 0.5),
                      activeThumbColor: primaryColor,
                    ),
                    borderColor: borderColor,
                  ),
                  Divider(color: borderColor, height: 1),

                  // Language
                  _SettingsTile(
                    leading: Text(currentLang?.flag ?? '',
                        style: const TextStyle(fontSize: 20)),
                    title: 'Language',
                    titleColor: textColor,
                    subtitle: currentLang?.name,
                    subtitleColor: textSecondary,
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    borderColor: borderColor,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => LanguagePickerModal(
                        selectedCode: settings.language,
                      ),
                    ),
                  ),
                  Divider(color: borderColor, height: 1),

                  // Logout
                  _SettingsTile(
                    leading: Icon(Icons.logout_rounded, color: errorColor),
                    title: 'Logout',
                    titleColor: errorColor,
                    borderColor: borderColor,
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondary,
  ) {
    if (_isLoadingStats) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
        children: List.generate(
          4,
          (_) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLoader(height: 16, width: 40),
                SizedBox(height: 6),
                SkeletonLoader(height: 10, width: 60),
              ],
            ),
          ),
        ),
      );
    }

    if (_dailyStats == null) {
      return Text(
        'No daily stats yet',
        style: TextStyle(color: textSecondary, fontSize: 14),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: [
        _DailyStatCard(
          emoji: '\u{1F525}',
          label: 'Streak',
          value: '${_dailyStats!.currentStreak}',
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          textSecondary: textSecondary,
        ),
        _DailyStatCard(
          emoji: '\u{26A1}',
          label: 'Best Streak',
          value: '${_dailyStats!.longestStreak}',
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          textSecondary: textSecondary,
        ),
        _DailyStatCard(
          emoji: '\u{1F3AF}',
          label: 'Accuracy',
          value: '${_dailyStats!.accuracy}%',
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          textSecondary: textSecondary,
        ),
        _DailyStatCard(
          emoji: '\u{1F4C5}',
          label: 'Total Days',
          value: '${_dailyStats!.totalAttempts}',
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  Widget _buildTestHistory(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondary,
    Color primaryColor,
  ) {
    if (_isLoadingHistory) {
      return Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: const Row(
                children: [
                  SkeletonLoader(height: 44, width: 44, borderRadius: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(height: 14, width: double.infinity),
                        SizedBox(height: 6),
                        SkeletonLoader(height: 10, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final items = _historyResponse?.items ?? [];
    if (items.isEmpty) {
      return Text(
        'No tests yet',
        style: TextStyle(color: textSecondary, fontSize: 14),
      );
    }

    return Column(
      children: items.map((item) {
        final celebrity = getCelebrityByKey(item.celebrityMatch);
        final modeLabel = item.mode == 'FULL_ANALYSIS'
            ? '\u{1F9E0} Full Analysis'
            : '\u{26A1} Arcade';

        return GestureDetector(
          onTap: () => context.push('/history/${item.testSessionId}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                // IQ circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.15),
                    border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      '${item.iqScore}',
                      style: TextStyle(
                        fontSize: 14,
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
                      Text(
                        modeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AutoSizeText(
                        '${celebrity.emoji} ${celebrity.label}',
                        maxLines: 1,
                        minFontSize: 10,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        _formatDate(item.completedAt),
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textSecondary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Daily Stat Card ──
class _DailyStatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color textSecondary;

  const _DailyStatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  value,
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                AutoSizeText(
                  label,
                  maxLines: 1,
                  minFontSize: 8,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Tile ──
class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Color titleColor;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final Color borderColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.titleColor,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/leaderboard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../widgets/ui/neon_text.dart';
import '../../widgets/ui/skeleton_loader.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final notifier = ref.read(leaderboardProvider.notifier);
    notifier.loadGlobal();
    notifier.loadUserRank();
    final user = ref.read(authProvider).user;
    if (user?.country != null) {
      notifier.loadCountry(user!.country!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;

    final leaderboard = ref.watch(leaderboardProvider);
    final auth = ref.watch(authProvider);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: NeonText(
            'Rankings',
            fontSize: 24,
            color: primaryColor,
            glow: isDark,
          ),
        ),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: primaryColor,
            unselectedLabelColor: textSecondary,
            indicatorColor: primaryColor,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: '\u{1F30D}  Global'),
              Tab(text: '\u{1F3C1}  Country'),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _LeaderboardTab(
                entries: leaderboard.global?.entries,
                isLoading: leaderboard.isLoadingGlobal,
                error: leaderboard.globalError,
                currentUserId: auth.user?.id,
                onRefresh: () async {
                  await ref.read(leaderboardProvider.notifier).loadGlobal();
                },
              ),
              _LeaderboardTab(
                entries: leaderboard.country?.entries,
                isLoading: leaderboard.isLoadingCountry,
                error: leaderboard.countryError,
                currentUserId: auth.user?.id,
                onRefresh: () async {
                  final user = ref.read(authProvider).user;
                  if (user?.country != null) {
                    await ref
                        .read(leaderboardProvider.notifier)
                        .loadCountry(user!.country!);
                  }
                },
              ),
            ],
          ),
        ),

        // Sticky rank footer
        _UserRankFooter(
          userRank: leaderboard.userRank,
          isLoading: leaderboard.userRank == null && leaderboard.isLoading,
        ),
      ],
    );
  }
}

// ── Leaderboard Tab ──
class _LeaderboardTab extends StatelessWidget {
  final List<LeaderboardEntry>? entries;
  final bool isLoading;
  final String? error;
  final String? currentUserId;
  final Future<void> Function() onRefresh;

  const _LeaderboardTab({
    required this.entries,
    required this.isLoading,
    this.error,
    this.currentUserId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;

    if (isLoading && entries == null) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 10,
        itemBuilder: (_, _) => const _SkeletonRow(),
      );
    }

    if (error != null && entries == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u{26A0}\u{FE0F}', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ],
          ),
        ),
      );
    }

    if (entries == null || entries!.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 100),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\u{1F3C6}', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No rankings yet',
                    style: TextStyle(fontSize: 16, color: textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries!.length,
        itemBuilder: (context, index) {
          final entry = entries![index];
          final isMe = entry.userId == currentUserId;
          return _EntryTile(entry: entry, isCurrentUser: isMe);
        },
      ),
    );
  }
}

// ── Entry Tile ──
class _EntryTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _EntryTile({required this.entry, required this.isCurrentUser});

  String _medal(int rank) {
    switch (rank) {
      case 1:
        return '\u{1F947}';
      case 2:
        return '\u{1F948}';
      case 3:
        return '\u{1F949}';
      default:
        return '#$rank';
    }
  }

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

    final medal = _medal(entry.rank);
    final isMedal = entry.rank <= 3;
    final displayName = entry.displayName ?? entry.username;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? primaryColor.withValues(alpha: 0.12)
            : surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? primaryColor : borderColor,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: isMedal
                ? Text(medal,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center)
                : Text(medal,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: primaryColor.withValues(alpha: 0.2),
            backgroundImage: entry.avatarUrl != null
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: entry.avatarUrl == null
                ? Text(initial,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ))
                : null,
          ),
          const SizedBox(width: 10),

          // Name + country
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  displayName,
                  maxLines: 1,
                  minFontSize: 11,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isCurrentUser ? primaryColor : textColor,
                  ),
                ),
                if (entry.country != null)
                  Text(
                    entry.country!,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
              ],
            ),
          ),

          // IQ Score
          Text(
            '${entry.iqScore}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton Row ──
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SkeletonLoader(height: 20, width: 30, borderRadius: 6),
          const SizedBox(width: 10),
          const SkeletonLoader(height: 36, width: 36, borderRadius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(height: 14, width: double.infinity),
                SizedBox(height: 4),
                SkeletonLoader(height: 10, width: 80),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const SkeletonLoader(height: 20, width: 40, borderRadius: 6),
        ],
      ),
    );
  }
}

// ── User Rank Footer ──
class _UserRankFooter extends StatelessWidget {
  final UserRankInfo? userRank;
  final bool isLoading;

  const _UserRankFooter({this.userRank, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Text(
            'Your Rank',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Spacer(),
          if (isLoading) ...[
            const SkeletonLoader(height: 28, width: 80, borderRadius: 14),
          ] else ...[
            _RankChip(
              label: '\u{1F30D}',
              value: userRank?.globalRank != null
                  ? '#${userRank!.globalRank}'
                  : '\u{2014}',
              color: primaryColor,
            ),
            const SizedBox(width: 8),
            _RankChip(
              label: '\u{1F3C1}',
              value: userRank?.countryRank != null
                  ? '#${userRank!.countryRank}'
                  : '\u{2014}',
              color: primaryColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _RankChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RankChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

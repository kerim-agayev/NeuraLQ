import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/daily_provider.dart';
import '../../providers/leaderboard_provider.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

class MainTabs extends ConsumerStatefulWidget {
  const MainTabs({super.key});

  @override
  ConsumerState<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends ConsumerState<MainTabs> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) {
      // Home tab — refresh user + daily status
      ref.read(authProvider.notifier).refreshUser();
      ref.read(dailyProvider.notifier).loadToday();
    } else if (index == 1) {
      // Ranks tab — refresh leaderboard data
      final notifier = ref.read(leaderboardProvider.notifier);
      notifier.loadGlobal();
      notifier.loadUserRank();
      final user = ref.read(authProvider).user;
      if (user?.country != null) {
        notifier.loadCountry(user!.country!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final unselectedColor =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textDim;
    final navBgColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: 'nav.home'.tr(),
                    isSelected: _currentIndex == 0,
                    selectedColor: primaryColor,
                    unselectedColor: unselectedColor,
                    onTap: () => _onTabTap(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.leaderboard_rounded,
                    label: 'nav.ranks'.tr(),
                    isSelected: _currentIndex == 1,
                    selectedColor: primaryColor,
                    unselectedColor: unselectedColor,
                    onTap: () => _onTabTap(1),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_rounded,
                    label: 'nav.profile'.tr(),
                    isSelected: _currentIndex == 2,
                    selectedColor: primaryColor,
                    unselectedColor: unselectedColor,
                    onTap: () => _onTabTap(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

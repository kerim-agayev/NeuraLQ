import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../constants/languages.dart';
import '../../providers/settings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/ui/neon_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = 'en';

  List<_OnboardingSlide> get _slides => [
    _OnboardingSlide(
      emoji: '\u{1F9E0}',
      title: 'onboarding.slide1Title'.tr(),
      description: 'onboarding.slide1Desc'.tr(),
    ),
    _OnboardingSlide(
      emoji: '\u{1F30D}',
      title: 'onboarding.slide2Title'.tr(),
      description: 'onboarding.slide2Desc'.tr(),
    ),
    _OnboardingSlide(
      emoji: '\u{1F310}',
      title: 'onboarding.slide3Title'.tr(),
      description: 'onboarding.slide3Desc'.tr(),
    ),
  ];

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _getStarted() async {
    // Save language & onboarding status
    await ref.read(settingsProvider.notifier).setLanguage(_selectedLanguage);
    await StorageService.setOnboardingDone(true);

    if (!mounted) return;

    // Update app locale
    final locale = Locale(_selectedLanguage);
    context.setLocale(locale);

    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final isLanguagePage = index == 2;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji
                        Text(
                          slide.emoji,
                          style: const TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        AutoSizeText(
                          slide.title,
                          maxLines: 1,
                          minFontSize: 18,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        AutoSizeText(
                          slide.description,
                          maxLines: 2,
                          minFontSize: 12,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondary,
                          ),
                        ),

                        // Language grid on last slide
                        if (isLanguagePage) ...[
                          const SizedBox(height: 32),
                          _buildLanguageGrid(
                            primaryColor,
                            textColor,
                            isDark,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section: dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => Container(
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _currentPage
                              ? primaryColor
                              : primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: _currentPage == _slides.length - 1
                        ? NeonButton(
                            text: 'onboarding.getStarted'.tr(),
                            onPressed: _getStarted,
                            primary: isDark
                                ? CyberpunkColors.primary
                                : CleanColors.primary,
                            secondary: isDark
                                ? CyberpunkColors.secondary
                                : CleanColors.secondary,
                          )
                        : NeonButton(
                            text: 'common.next'.tr(),
                            onPressed: _nextPage,
                            primary: isDark
                                ? CyberpunkColors.primary
                                : CleanColors.primary,
                            secondary: isDark
                                ? CyberpunkColors.secondary
                                : CleanColors.secondary,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageGrid(
    Color primaryColor,
    Color textColor,
    bool isDark,
  ) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.95,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: appLanguages.length,
        itemBuilder: (context, index) {
          final lang = appLanguages[index];
          final isSelected = _selectedLanguage == lang.code;

          return GestureDetector(
            onTap: () => setState(() => _selectedLanguage = lang.code),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.2)
                    : isDark
                        ? CyberpunkColors.surface
                        : CleanColors.surfaceLight,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : isDark
                          ? CyberpunkColors.border
                          : CleanColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(
                        lang.code.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryColor : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingSlide {
  final String emoji;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

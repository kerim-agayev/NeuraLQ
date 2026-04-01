import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
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
      emoji: '\u{1F680}',
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
    await StorageService.setOnboardingDone(true);
    if (!mounted) return;
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
                  final isLastPage = index == 2;

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

                        // Feature highlights on last slide
                        if (isLastPage) ...[
                          const SizedBox(height: 36),
                          _buildFeatureHighlights(
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

  Widget _buildFeatureHighlights(
    Color primaryColor,
    Color textColor,
    bool isDark,
  ) {
    final features = [
      _Feature('\u{1F9EA}', 'onboarding.feature1'.tr()),
      _Feature('\u{1F3C6}', 'onboarding.feature2'.tr()),
      _Feature('\u{1F4CA}', 'onboarding.feature3'.tr()),
      _Feature('\u{26A1}', 'onboarding.feature4'.tr()),
    ];

    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(f.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

class _Feature {
  final String emoji;
  final String label;

  const _Feature(this.emoji, this.label);
}

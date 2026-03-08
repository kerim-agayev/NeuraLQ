import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/test_provider.dart';
import '../../widgets/ui/brain_loader.dart';

class SelectModeScreen extends ConsumerWidget {
  const SelectModeScreen({super.key});

  Future<void> _startTest(
    WidgetRef ref,
    BuildContext context,
    String mode,
  ) async {
    final language = ref.read(settingsProvider).language;
    await ref.read(testProvider.notifier).startSession(
          mode: mode,
          language: language,
        );

    final state = ref.read(testProvider);
    if (state.error != null) {
      Fluttertoast.showToast(
        msg: state.error!,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (state.session != null && context.mounted) {
      context.go('/test/session');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final secondaryColor =
        isDark ? CyberpunkColors.secondary : CleanColors.secondary;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;

    final test = ref.watch(testProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text('Select Mode',
            style: TextStyle(color: textColor, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text('\u{1F9E0}',
                        style: const TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: AutoSizeText(
                      'Choose your test mode',
                      maxLines: 1,
                      minFontSize: 14,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: AutoSizeText(
                      'Each mode has different question counts and analysis depth',
                      maxLines: 2,
                      minFontSize: 11,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Arcade mode
                  _ModeCard(
                    title: 'Arcade',
                    emoji: '\u{26A1}',
                    description: '15 questions • ~5 min',
                    detail: 'Quick test with core categories',
                    gradient: [primaryColor, secondaryColor],
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    onTap: () => _startTest(ref, context, 'ARCADE'),
                  ),
                  const SizedBox(height: 16),

                  // Full Analysis mode
                  _ModeCard(
                    title: 'Full Analysis',
                    emoji: '\u{1F4CA}',
                    description: '40 questions • ~15 min',
                    detail:
                        'Complete cognitive analysis with all categories',
                    gradient: [secondaryColor, primaryColor],
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    onTap: () =>
                        _startTest(ref, context, 'FULL_ANALYSIS'),
                  ),
                ],
              ),
            ),
          ),
          if (test.isLoading)
            const Positioned.fill(
              child: BrainLoader(
                message: 'Preparing your test...',
                overlay: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final String detail;
  final List<Color> gradient;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color textSecondary;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.detail,
    required this.gradient,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: gradient),
              ),
              child: Center(
                child:
                    Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    title,
                    maxLines: 1,
                    minFontSize: 14,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    description,
                    maxLines: 1,
                    minFontSize: 11,
                    style: TextStyle(fontSize: 14, color: gradient[0]),
                  ),
                  const SizedBox(height: 2),
                  AutoSizeText(
                    detail,
                    maxLines: 1,
                    minFontSize: 9,
                    style:
                        TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textSecondary),
          ],
        ),
      ),
    );
  }
}

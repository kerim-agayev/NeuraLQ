import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/ui/neon_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Defensive bootstrap: any hang or thrown error must not block navigation.
    // Secure storage / network calls on a fresh Play Store install can stall —
    // wrap each step with a timeout and treat failures as logged-out.
    bool isLoggedIn = false;
    bool onboardingDone = false;

    try {
      await ref
          .read(settingsProvider.notifier)
          .loadSettings()
          .timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (e) {
      debugPrint('Splash loadSettings failed: $e');
    }

    try {
      final results = await Future.wait([
        Future<bool>.delayed(const Duration(milliseconds: 1500), () => true),
        ref
            .read(authProvider.notifier)
            .loadUser()
            .timeout(const Duration(seconds: 5), onTimeout: () => false),
      ]);
      isLoggedIn = results[1];
    } catch (e) {
      debugPrint('Splash auth check failed: $e');
    }

    if (!isLoggedIn) {
      try {
        onboardingDone = await StorageService.isOnboardingDone()
            .timeout(const Duration(seconds: 3), onTimeout: () => false);
      } catch (e) {
        debugPrint('Splash onboarding check failed: $e');
      }
    }

    if (!mounted) return;

    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go(onboardingDone ? '/login' : '/onboarding');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brain emoji in circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: const Center(
                    child: Text('\u{1F9E0}', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 24),

                // NeuralQ text
                NeonText(
                  'NeuralQ',
                  fontSize: 36,
                  color: primaryColor,
                  glow: isDark,
                ),
                const SizedBox(height: 32),

                // Loading spinner
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/tabs/main_tabs.dart';
import '../screens/test/select_mode_screen.dart';
import '../screens/test/session_screen.dart';
import '../screens/test/result_screen.dart';

// Placeholder screens for future steps
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, _) => const RegisterScreen(),
    ),
    // Main tabs (Home, Ranks, Profile)
    GoRoute(
      path: '/home',
      builder: (_, _) => const MainTabs(),
    ),
    // Test routes
    GoRoute(
      path: '/test/select-mode',
      builder: (_, _) => const SelectModeScreen(),
    ),
    GoRoute(
      path: '/test/session',
      builder: (_, _) => const SessionScreen(),
    ),
    GoRoute(
      path: '/test/result',
      builder: (_, _) => const ResultScreen(),
    ),
    // Daily & History
    GoRoute(
      path: '/daily',
      builder: (_, _) => const _PlaceholderScreen('Daily Challenge'),
    ),
    GoRoute(
      path: '/history/:id',
      builder: (_, state) => _PlaceholderScreen(
        'History ${state.pathParameters['id']}',
      ),
    ),
  ],
);

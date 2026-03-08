import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

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
      builder: (_, _) => const _PlaceholderScreen('Login'),
    ),
    GoRoute(
      path: '/register',
      builder: (_, _) => const _PlaceholderScreen('Register'),
    ),
    // Tab routes - will be replaced with ShellRoute in ADIM 6
    GoRoute(
      path: '/home',
      builder: (_, _) => const _PlaceholderScreen('Home'),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (_, _) => const _PlaceholderScreen('Leaderboard'),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, _) => const _PlaceholderScreen('Profile'),
    ),
    // Test routes
    GoRoute(
      path: '/test/select-mode',
      builder: (_, _) => const _PlaceholderScreen('Select Mode'),
    ),
    GoRoute(
      path: '/test/session',
      builder: (_, _) => const _PlaceholderScreen('Test Session'),
    ),
    GoRoute(
      path: '/test/result',
      builder: (_, _) => const _PlaceholderScreen('Result'),
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

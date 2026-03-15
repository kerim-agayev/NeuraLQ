import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';

class NeuralQApp extends ConsumerStatefulWidget {
  const NeuralQApp({super.key});

  @override
  ConsumerState<NeuralQApp> createState() => _NeuralQAppState();
}

class _NeuralQAppState extends ConsumerState<NeuralQApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load settings on app start
    Future.microtask(() {
      ref.read(settingsProvider.notifier).loadSettings();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User came back to app — silently refresh token + wake up backend
      final auth = ref.read(authProvider);
      if (auth.user != null) {
        ref.read(authProvider.notifier).refreshUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'NeuralQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clean,
      darkTheme: AppTheme.cyberpunk,
      themeMode: settings.isLoaded ? settings.flutterThemeMode : ThemeMode.dark,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: appRouter,
    );
  }
}

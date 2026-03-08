import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'config/theme.dart';
import 'providers/settings_provider.dart';

class NeuralQApp extends ConsumerStatefulWidget {
  const NeuralQApp({super.key});

  @override
  ConsumerState<NeuralQApp> createState() => _NeuralQAppState();
}

class _NeuralQAppState extends ConsumerState<NeuralQApp> {
  @override
  void initState() {
    super.initState();
    // Load settings on app start
    Future.microtask(() {
      ref.read(settingsProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'NeuralQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clean,
      darkTheme: AppTheme.cyberpunk,
      themeMode: settings.isLoaded ? settings.flutterThemeMode : ThemeMode.dark,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const _PlaceholderHome(),
    );
  }
}

// Temporary placeholder - will be replaced by GoRouter in ADIM 4
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;

    return Scaffold(
      body: Center(
        child: Text(
          'NeuralQ',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}

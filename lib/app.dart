import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'config/theme.dart';

class NeuralQApp extends ConsumerWidget {
  const NeuralQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NeuralQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberpunk,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const Scaffold(
        body: Center(
          child: Text(
            'NeuralQ',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CyberpunkColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

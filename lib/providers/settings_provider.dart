import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// ── State ──
class SettingsState {
  final String themeMode; // 'cyberpunk' | 'clean'
  final String language;
  final bool isLoaded;

  const SettingsState({
    this.themeMode = 'cyberpunk',
    this.language = 'en',
    this.isLoaded = false,
  });

  bool get isCyberpunk => themeMode == 'cyberpunk';
  ThemeMode get flutterThemeMode =>
      isCyberpunk ? ThemeMode.dark : ThemeMode.light;

  SettingsState copyWith({
    String? themeMode,
    String? language,
    bool? isLoaded,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

// ── Notifier ──
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  Future<void> loadSettings() async {
    try {
      final theme = await StorageService.getThemePreference();
      final language = await StorageService.getLanguage();
      state = SettingsState(
        themeMode: theme,
        language: language,
        isLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state.isCyberpunk ? 'clean' : 'cyberpunk';
    state = state.copyWith(themeMode: newTheme);
    try {
      await StorageService.setThemePreference(newTheme);
    } catch (_) {}
  }

  Future<void> setTheme(String theme) async {
    state = state.copyWith(themeMode: theme);
    try {
      await StorageService.setThemePreference(theme);
    } catch (_) {}
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    try {
      await StorageService.setLanguage(language);
    } catch (_) {}
  }
}

// ── Provider ──
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

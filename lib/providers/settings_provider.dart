import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

const _supportedLanguageCodes = {
  'en', 'tr', 'de', 'fr', 'es', 'it', 'pt', 'ru',
  'ar', 'zh', 'ja', 'ko', 'hi', 'az', 'pl', 'id',
};

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
      final stored = await StorageService.getLanguage();
      final String language;
      if (stored != null) {
        language = stored;
      } else {
        // First launch: walk the device's preferred locale list (in priority
        // order) and pick the first one we support. Iterating `locales`
        // (plural) is more reliable than `locale` (single) — on some devices
        // the singular value can be the framework default before the OS has
        // reported its actual preference.
        final locales = WidgetsBinding.instance.platformDispatcher.locales;
        String? detected;
        for (final locale in locales) {
          if (_supportedLanguageCodes.contains(locale.languageCode)) {
            detected = locale.languageCode;
            break;
          }
        }
        language = detected ?? 'en';
        debugPrint(
          'Settings first-launch: detected language=$language from $locales',
        );
        await StorageService.setLanguage(language);
      }
      state = SettingsState(
        themeMode: theme,
        language: language,
        isLoaded: true,
      );
    } catch (e) {
      debugPrint('loadSettings failed: $e');
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

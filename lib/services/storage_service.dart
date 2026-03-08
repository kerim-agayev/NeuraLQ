import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();

  // ── Tokens (Secure) ──
  static Future<void> saveAccessToken(String token) =>
      _secureStorage.write(key: storageKeyAccessToken, value: token);

  static Future<String?> getAccessToken() =>
      _secureStorage.read(key: storageKeyAccessToken);

  static Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(key: storageKeyRefreshToken, value: token);

  static Future<String?> getRefreshToken() =>
      _secureStorage.read(key: storageKeyRefreshToken);

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: storageKeyAccessToken);
    await _secureStorage.delete(key: storageKeyRefreshToken);
  }

  // ── Onboarding ──
  static Future<void> setOnboardingDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKeyOnboardingDone, done);
  }

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(storageKeyOnboardingDone) ?? false;
  }

  // ── Theme ──
  static Future<void> setThemePreference(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKeyThemePreference, theme);
  }

  static Future<String> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(storageKeyThemePreference) ?? 'cyberpunk';
  }

  // ── Language ──
  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKeyLanguage, language);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(storageKeyLanguage) ?? 'en';
  }

  // ── Test Backup ──
  static Future<void> saveTestBackup(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKeyTestBackup, json);
  }

  static Future<String?> getTestBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(storageKeyTestBackup);
  }

  static Future<void> clearTestBackup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKeyTestBackup);
  }
}

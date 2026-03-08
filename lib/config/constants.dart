const String apiBaseUrl = 'http://192.168.100.37:3000/api';
const Duration apiTimeout = Duration(seconds: 30);
const String googleWebClientId =
    '790107378278-eoa9v5o8biuffc7ks4i5dge305v86nho.apps.googleusercontent.com';

// Storage Keys
const String storageKeyAccessToken = 'accessToken';
const String storageKeyRefreshToken = 'refreshToken';
const String storageKeyOnboardingDone = 'onboardingDone';
const String storageKeyThemePreference = 'themePreference';
const String storageKeyLanguage = 'language';
const String storageKeyTestBackup = 'testBackup';

// Font Sizes
class FontSizes {
  static const double h1 = 32.0;
  static const double h2 = 24.0;
  static const double h3 = 20.0;
  static const double h4 = 18.0;
  static const double body = 16.0;
  static const double bodySmall = 14.0;
  static const double caption = 12.0;
  static const double tiny = 10.0;
  static const double minFontSize = 8.0;
}

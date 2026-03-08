import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
// CYBERPUNK THEME (Dark - Default)
// ═══════════════════════════════════════════
class CyberpunkColors {
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceLight = Color(0xFF1A1A2E);

  static const Color primary = Color(0xFF00F5FF);
  static const Color primaryDim = Color(0x3300F5FF);
  static const Color secondary = Color(0xFFBF00FF);
  static const Color accent = Color(0xFFFF006E);

  static const Color success = Color(0xFF39FF14);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF073A);

  static const Color text = Color(0xFFE0E0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textDim = Color(0xFF555577);

  static const Color border = Color(0xFF2A2A3E);
  static const Color card = Color(0xFF151520);
}

// ═══════════════════════════════════════════
// CLEAN THEME (Light)
// ═══════════════════════════════════════════
class CleanColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);

  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDim = Color(0x223B82F6);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFFEC4899);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color text = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDim = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE2E8F0);
  static const Color card = Color(0xFFFFFFFF);
}

// ═══════════════════════════════════════════
// THEME DATA
// ═══════════════════════════════════════════
class AppTheme {
  static ThemeData cyberpunk = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: CyberpunkColors.background,
    // Material 3 is enabled by default in Flutter 3.11+
    colorScheme: const ColorScheme.dark(
      primary: CyberpunkColors.primary,
      secondary: CyberpunkColors.secondary,
      error: CyberpunkColors.error,
      surface: CyberpunkColors.surface,
      onSurface: CyberpunkColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CyberpunkColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: CyberpunkColors.primary),
      titleTextStyle: TextStyle(
        color: CyberpunkColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CyberpunkColors.background,
      selectedItemColor: CyberpunkColors.primary,
      unselectedItemColor: CyberpunkColors.textSecondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CyberpunkColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CyberpunkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CyberpunkColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: CyberpunkColors.primary, width: 2),
      ),
    ),
  );

  static ThemeData clean = ThemeData.light().copyWith(
    scaffoldBackgroundColor: CleanColors.background,
    // Material 3 is enabled by default in Flutter 3.11+
    colorScheme: const ColorScheme.light(
      primary: CleanColors.primary,
      secondary: CleanColors.secondary,
      error: CleanColors.error,
      surface: CleanColors.surface,
      onSurface: CleanColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CleanColors.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: CleanColors.primary),
      titleTextStyle: TextStyle(
        color: CleanColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CleanColors.surface,
      selectedItemColor: CleanColors.primary,
      unselectedItemColor: CleanColors.textDim,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CleanColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CleanColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CleanColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CleanColors.primary, width: 2),
      ),
    ),
  );
}

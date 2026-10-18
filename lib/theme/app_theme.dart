import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// High-contrast, large-type themes designed for older adults.
class AppTheme {
  // Default (light) palette — used by widgets via AppTheme.*
  static const Color bg = Color(0xFFF7F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A2332);
  static const Color inkSoft = Color(0xFF4A5568);
  static const Color accent = Color(0xFF0B6E4F);
  static const Color accentSoft = Color(0xFFD8F3E7);
  static const Color highlight = Color(0xFFE8F0FE);
  static const Color selected = Color(0xFFB8D4F0);
  static const Color sameNumber = Color(0xFFC5E8D8);
  static const Color error = Color(0xFFB42318);
  static const Color errorBg = Color(0xFFFCE8E6);
  static const Color given = Color(0xFF1A2332);
  static const Color user = Color(0xFF1565C0);
  static const Color gridLine = Color(0xFF94A3B8);
  static const Color gridBold = Color(0xFF1A2332);
  static const Color warm = Color(0xFFC45C26);

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: brightness == Brightness.dark ? colors.bg : Colors.white,
        secondary: colors.user,
        onSecondary: Colors.white,
        error: colors.error,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.ink,
      ),
      extensions: [colors],
    );

    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
    );

    return base.copyWith(
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 40,
          letterSpacing: -0.5,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 28,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.4),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        foregroundColor: colors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: colors.ink,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: colors.ink,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: colors.inkSoft,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor:
              brightness == Brightness.dark ? colors.bg : Colors.white,
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: colors.ink, width: 2),
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.ink.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}

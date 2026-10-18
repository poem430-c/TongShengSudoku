import 'package:flutter/material.dart';

/// App color palette that switches with light / dark theme.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.accentSoft,
    required this.highlight,
    required this.selected,
    required this.sameNumber,
    required this.error,
    required this.errorBg,
    required this.given,
    required this.user,
    required this.gridLine,
    required this.gridBold,
    required this.warm,
    required this.heroTop,
    required this.heroBottom,
    required this.trophyBg,
  });

  final Color bg;
  final Color surface;
  final Color ink;
  final Color inkSoft;
  final Color accent;
  final Color accentSoft;
  final Color highlight;
  final Color selected;
  final Color sameNumber;
  final Color error;
  final Color errorBg;
  final Color given;
  final Color user;
  final Color gridLine;
  final Color gridBold;
  final Color warm;
  final Color heroTop;
  final Color heroBottom;
  final Color trophyBg;

  static const light = AppColors(
    bg: Color(0xFFF7F4EF),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF1A2332),
    inkSoft: Color(0xFF4A5568),
    accent: Color(0xFF0B6E4F),
    accentSoft: Color(0xFFD8F3E7),
    highlight: Color(0xFFE8F0FE),
    selected: Color(0xFFB8D4F0),
    sameNumber: Color(0xFFC5E8D8),
    error: Color(0xFFB42318),
    errorBg: Color(0xFFFCE8E6),
    given: Color(0xFF1A2332),
    user: Color(0xFF1565C0),
    gridLine: Color(0xFF94A3B8),
    gridBold: Color(0xFF1A2332),
    warm: Color(0xFFC45C26),
    heroTop: Color(0xFFE8F5F0),
    heroBottom: Color(0xFFFFF6EE),
    trophyBg: Color(0xFFFFF3D6),
  );

  static const dark = AppColors(
    bg: Color(0xFF0E1116),
    surface: Color(0xFF1A1F27),
    ink: Color(0xFFF5F7FA),
    // Brighter soft text so secondary lines stay readable on dark cards.
    inkSoft: Color(0xFFC9D1DC),
    accent: Color(0xFF4AD6A3),
    accentSoft: Color(0xFF24352E),
    highlight: Color(0xFF2A3340),
    selected: Color(0xFF334A63),
    sameNumber: Color(0xFF2F453A),
    error: Color(0xFFFF8A80),
    errorBg: Color(0xFF3A2222),
    given: Color(0xFFF5F7FA),
    user: Color(0xFF8EC0FF),
    gridLine: Color(0xFF5A687A),
    gridBold: Color(0xFFE2E8F0),
    warm: Color(0xFFFFB074),
    heroTop: Color(0xFF12161C),
    heroBottom: Color(0xFF16141A),
    trophyBg: Color(0xFF2F2A1C),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? AppColors.light;
  }

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? ink,
    Color? inkSoft,
    Color? accent,
    Color? accentSoft,
    Color? highlight,
    Color? selected,
    Color? sameNumber,
    Color? error,
    Color? errorBg,
    Color? given,
    Color? user,
    Color? gridLine,
    Color? gridBold,
    Color? warm,
    Color? heroTop,
    Color? heroBottom,
    Color? trophyBg,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      highlight: highlight ?? this.highlight,
      selected: selected ?? this.selected,
      sameNumber: sameNumber ?? this.sameNumber,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      given: given ?? this.given,
      user: user ?? this.user,
      gridLine: gridLine ?? this.gridLine,
      gridBold: gridBold ?? this.gridBold,
      warm: warm ?? this.warm,
      heroTop: heroTop ?? this.heroTop,
      heroBottom: heroBottom ?? this.heroBottom,
      trophyBg: trophyBg ?? this.trophyBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      sameNumber: Color.lerp(sameNumber, other.sameNumber, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      given: Color.lerp(given, other.given, t)!,
      user: Color.lerp(user, other.user, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      gridBold: Color.lerp(gridBold, other.gridBold, t)!,
      warm: Color.lerp(warm, other.warm, t)!,
      heroTop: Color.lerp(heroTop, other.heroTop, t)!,
      heroBottom: Color.lerp(heroBottom, other.heroBottom, t)!,
      trophyBg: Color.lerp(trophyBg, other.trophyBg, t)!,
    );
  }
}

import 'package:flutter/material.dart';

class DoomNotesTheme {
  DoomNotesTheme._();

  // Set once per build by the app root (see main.dart) before anything
  // else reads a color below. This lets every existing call site in the
  // app — `DoomNotesTheme.ink`, `DoomNotesTheme.muted`, etc. — stay
  // exactly as written while actually switching with light/dark mode,
  // instead of requiring every widget to be rewritten to thread
  // `BuildContext` through for a color lookup.
  static bool _dark = false;
  static void setDark(bool value) => _dark = value;
  static bool get isDark => _dark;

  // ---- Surfaces & text (flip with brightness) ----
  static Color get ink => _dark ? const Color(0xFFF2F2F7) : const Color(0xFF14161F);
  static Color get canvas => _dark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);
  static Color get surface => _dark ? const Color(0xFF1C1C24) : const Color(0xFFFFFFFF);
  static Color get muted => _dark ? const Color(0xFF9A9FB0) : const Color(0xFF687082);
  static Color get border => _dark ? const Color(0xFF2E2E38) : const Color(0xFFE5E7EC);

  // ---- Accents (same hue both modes, brightened slightly for dark bg) ----
  static Color get violet => _dark ? const Color(0xFF8B7FFF) : const Color(0xFF6557E8);
  static Color get violetSoft => _dark ? const Color(0xFF2A2650) : const Color(0xFFEDEBFF);
  static Color get mint => _dark ? const Color(0xFF3FCBA8) : const Color(0xFF17A78B);
  static Color get amber => _dark ? const Color(0xFFFFC15C) : const Color(0xFFF5A524);
  static Color get rose => _dark ? const Color(0xFFF07B93) : const Color(0xFFE85D75);
  static Color get blue => _dark ? const Color(0xFF5B96FF) : const Color(0xFF2878F0);

  static const radiusSmall = 12.0;
  static const radiusMedium = 18.0;
  static const radiusLarge = 24.0;

  static ThemeData lightTheme() => _build(Brightness.light);
  static ThemeData darkTheme() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    // Resolve a fixed snapshot of colors for THIS brightness, regardless
    // of the current value of `_dark` — so light/dark ThemeData are each
    // internally consistent even before `setDark` has been called for
    // this build pass.
    final Color inkC = dark ? const Color(0xFFF2F2F7) : const Color(0xFF14161F);
    final Color canvasC = dark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);
    final Color surfaceC = dark ? const Color(0xFF1C1C24) : const Color(0xFFFFFFFF);
    final Color mutedC = dark ? const Color(0xFF9A9FB0) : const Color(0xFF687082);
    final Color borderC = dark ? const Color(0xFF2E2E38) : const Color(0xFFE5E7EC);
    final Color violetC = dark ? const Color(0xFF8B7FFF) : const Color(0xFF6557E8);

    final base = ThemeData(useMaterial3: true, brightness: brightness);

    return base.copyWith(
      scaffoldBackgroundColor: canvasC,
      colorScheme: ColorScheme.fromSeed(
        seedColor: violetC,
        brightness: brightness,
        surface: surfaceC,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasC,
        foregroundColor: inkC,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: inkC,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceC,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: borderC),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceC,
        hintStyle: TextStyle(color: mutedC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderC),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderC),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: violetC, width: 1.5),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w800,
          color: inkC,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: inkC,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: inkC,
        ),
        bodyMedium: TextStyle(
          color: inkC,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: mutedC,
          height: 1.35,
        ),
      ),
    );
  }
}

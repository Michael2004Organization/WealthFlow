import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const seed = Color(0xFF5267E8);
  static ThemeData light() => _create(Brightness.light);
  static ThemeData dark() => _create(Brightness.dark);
  static ThemeData _create(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(elevation: 0, color: scheme.surfaceContainerLow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: .45), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
      navigationRailTheme: const NavigationRailThemeData(groupAlignment: -0.75),
    );
  }
}

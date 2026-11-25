import 'package:flutter/material.dart';

/// The three looks the app can switch between.
///
/// * [bento]: graphite tiles of different sizes with petrol accents (dark).
/// * [terminal]: near-black, thin lines, monospace figures (dark).
/// * [classic]: today's petrol design, light, dark or following the system.
enum AppDesign {
  bento('Bento'),
  terminal('Terminal'),
  classic('Hell & Dunkel');

  const AppDesign(this.label);

  final String label;
}

/// A design together with its brightness setting.
///
/// Both are stored in the existing `themeMode` preference so no database
/// migration is needed: `bento`, `terminal`, or for [AppDesign.classic] one
/// of `system`, `light`, `dark`. Older app versions read an unknown value as
/// "system".
@immutable
class DesignChoice {
  const DesignChoice(this.design, this.mode);

  /// Reads a stored `themeMode` value; anything unknown is classic/system.
  factory DesignChoice.parse(String? value) => switch (value) {
    'bento' => const DesignChoice(AppDesign.bento, ThemeMode.dark),
    'terminal' => const DesignChoice(AppDesign.terminal, ThemeMode.dark),
    'light' => const DesignChoice(AppDesign.classic, ThemeMode.light),
    'dark' => const DesignChoice(AppDesign.classic, ThemeMode.dark),
    _ => const DesignChoice(AppDesign.classic, ThemeMode.system),
  };

  final AppDesign design;
  final ThemeMode mode;

  /// The value written to the `themeMode` preference.
  String get storedValue => switch (design) {
    AppDesign.bento => 'bento',
    AppDesign.terminal => 'terminal',
    AppDesign.classic => switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    },
  };

  /// All choices in menu order.
  static const all = [
    DesignChoice(AppDesign.bento, ThemeMode.dark),
    DesignChoice(AppDesign.terminal, ThemeMode.dark),
    DesignChoice(AppDesign.classic, ThemeMode.system),
    DesignChoice(AppDesign.classic, ThemeMode.light),
    DesignChoice(AppDesign.classic, ThemeMode.dark),
  ];

  /// Label for menus and the settings, e.g. "Hell & Dunkel · System".
  String get label => switch (design) {
    AppDesign.classic =>
      '${design.label} · ${switch (mode) {
        ThemeMode.light => 'Hell',
        ThemeMode.dark => 'Dunkel',
        ThemeMode.system => 'System',
      }}',
    _ => design.label,
  };

  @override
  bool operator ==(Object other) =>
      other is DesignChoice && other.design == design && other.mode == mode;

  @override
  int get hashCode => Object.hash(design, mode);
}

/// Shape and type decisions that differ per [AppDesign], beside the colors
/// in `WealthColors`.
@immutable
class DesignStyle extends ThemeExtension<DesignStyle> {
  const DesignStyle({
    required this.design,
    required this.radiusCard,
    required this.radiusControl,
    required this.outlinedCards,
    required this.displayFont,
    required this.numberFont,
  });

  final AppDesign design;

  /// Corner radius of cards and tiles.
  final double radiusCard;

  /// Corner radius of buttons, fields and chips.
  final double radiusControl;

  /// Cards drawn as a thin line instead of a filled surface.
  final bool outlinedCards;

  /// Font family for headings.
  final String displayFont;

  /// Font family for large figures (amounts, percentages).
  final String numberFont;

  static const bento = DesignStyle(
    design: AppDesign.bento,
    radiusCard: 28,
    radiusControl: 22,
    outlinedCards: false,
    displayFont: 'PlusJakartaSans',
    numberFont: 'PlusJakartaSans',
  );

  static const terminal = DesignStyle(
    design: AppDesign.terminal,
    radiusCard: 4,
    radiusControl: 4,
    outlinedCards: true,
    displayFont: 'JetBrainsMono',
    numberFont: 'JetBrainsMono',
  );

  static const classic = DesignStyle(
    design: AppDesign.classic,
    radiusCard: 20,
    radiusControl: 12,
    outlinedCards: true,
    displayFont: 'PlusJakartaSans',
    numberFont: 'PlusJakartaSans',
  );

  static DesignStyle forDesign(AppDesign design) => switch (design) {
    AppDesign.bento => bento,
    AppDesign.terminal => terminal,
    AppDesign.classic => classic,
  };

  static DesignStyle of(BuildContext context) =>
      Theme.of(context).extension<DesignStyle>() ?? classic;

  @override
  DesignStyle copyWith() => this;

  @override
  DesignStyle lerp(DesignStyle? other, double t) =>
      other == null || t < .5 ? this : other;
}

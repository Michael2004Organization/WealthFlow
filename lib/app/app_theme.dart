import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Colors with a meaning of their own, beside the Material color scheme.
///
/// Income and expense always come with a sign (+ / −) as well, so the two
/// can be told apart without color.
@immutable
class WealthColors extends ThemeExtension<WealthColors> {
  const WealthColors({
    required this.income,
    required this.incomeSoft,
    required this.expense,
    required this.expenseSoft,
    required this.neutral,
    required this.neutralSoft,
    required this.warning,
    required this.muted,
    required this.border,
    required this.ground,
    required this.hero,
    required this.onHero,
    required this.chart,
  });

  final Color income;
  final Color incomeSoft;
  final Color expense;
  final Color expenseSoft;
  final Color neutral;
  final Color neutralSoft;
  final Color warning;
  final Color muted;
  final Color border;
  final Color ground;
  final Color hero;
  final Color onHero;

  /// Series colors for charts, in order of use.
  final List<Color> chart;

  static const light = WealthColors(
    income: Color(0xff0a5f58),
    incomeSoft: Color(0xffe1f0ed),
    expense: Color(0xffa0440f),
    expenseSoft: Color(0xfffbe9dd),
    neutral: Color(0xff3f4a52),
    neutralSoft: Color(0xffeef0f3),
    warning: Color(0xffb7791f),
    muted: Color(0xff5b6670),
    border: Color(0xffe3e6e2),
    ground: Color(0xfff4f5f2),
    hero: Color(0xff0e6e66),
    onHero: Color(0xffffffff),
    chart: [
      Color(0xff0e6e66),
      Color(0xffd9822b),
      Color(0xff4fa79d),
      Color(0xff5b6f9e),
      Color(0xffa0440f),
      Color(0xff8c969e),
    ],
  );

  static const dark = WealthColors(
    income: Color(0xff5cc8b8),
    incomeSoft: Color(0xff1d3a36),
    expense: Color(0xfff0a06a),
    expenseSoft: Color(0xff3a2619),
    neutral: Color(0xffb4bfbc),
    neutralSoft: Color(0xff232c30),
    warning: Color(0xffe8b85c),
    muted: Color(0xff9aa6a3),
    border: Color(0xff263034),
    ground: Color(0xff0f1416),
    hero: Color(0xff123b37),
    onHero: Color(0xffffffff),
    chart: [
      Color(0xff5cc8b8),
      Color(0xffe8a35c),
      Color(0xff3f8f86),
      Color(0xff8fa3d6),
      Color(0xfff0a06a),
      Color(0xff9aa6a3),
    ],
  );

  static WealthColors of(BuildContext context) =>
      Theme.of(context).extension<WealthColors>() ?? light;

  /// Color for a signed amount: income, expense or neutral (transfers).
  Color amount({required bool income, bool neutral = false}) =>
      neutral ? this.neutral : (income ? this.income : expense);

  @override
  WealthColors copyWith() => this;

  @override
  WealthColors lerp(WealthColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return WealthColors(
      income: mix(income, other.income),
      incomeSoft: mix(incomeSoft, other.incomeSoft),
      expense: mix(expense, other.expense),
      expenseSoft: mix(expenseSoft, other.expenseSoft),
      neutral: mix(neutral, other.neutral),
      neutralSoft: mix(neutralSoft, other.neutralSoft),
      warning: mix(warning, other.warning),
      muted: mix(muted, other.muted),
      border: mix(border, other.border),
      ground: mix(ground, other.ground),
      hero: mix(hero, other.hero),
      onHero: mix(onHero, other.onHero),
      chart: [
        for (var i = 0; i < chart.length; i++)
          mix(chart[i], other.chart[i % other.chart.length]),
      ],
    );
  }
}

abstract final class AppTheme {
  static const bodyFont = 'Inter';
  static const displayFont = 'PlusJakartaSans';
  static const tabular = [FontFeature.tabularFigures()];

  /// Corner radii: cards, controls, small surfaces.
  static const radiusCard = 20.0;
  static const radiusControl = 12.0;
  static const radiusSmall = 8.0;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ColorScheme _scheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xff0e6e66),
        onPrimary: Color(0xffffffff),
        primaryContainer: Color(0xffe1f0ed),
        onPrimaryContainer: Color(0xff0a524c),
        secondary: Color(0xff3f4a52),
        onSecondary: Color(0xffffffff),
        secondaryContainer: Color(0xffeef0f3),
        onSecondaryContainer: Color(0xff121a1f),
        tertiary: Color(0xffa0440f),
        onTertiary: Color(0xffffffff),
        tertiaryContainer: Color(0xfffbe9dd),
        onTertiaryContainer: Color(0xff6e2d08),
        error: Color(0xffb3261e),
        onError: Color(0xffffffff),
        errorContainer: Color(0xfff9dedc),
        onErrorContainer: Color(0xff410e0b),
        surface: Color(0xffffffff),
        onSurface: Color(0xff121a1f),
        onSurfaceVariant: Color(0xff5b6670),
        surfaceContainerLowest: Color(0xffffffff),
        surfaceContainerLow: Color(0xffffffff),
        surfaceContainer: Color(0xfff6f7f5),
        surfaceContainerHigh: Color(0xfff0f2ef),
        surfaceContainerHighest: Color(0xffe9ece8),
        outline: Color(0xffcbd2ce),
        outlineVariant: Color(0xffe3e6e2),
        inverseSurface: Color(0xff1e272b),
        onInverseSurface: Color(0xffeef1ef),
        inversePrimary: Color(0xff5cc8b8),
        shadow: Color(0xff000000),
        scrim: Color(0xff000000),
      );
    }
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff2fa595),
      onPrimary: Color(0xff04201d),
      primaryContainer: Color(0xff1d3a36),
      onPrimaryContainer: Color(0xff8fdccf),
      secondary: Color(0xffb4bfbc),
      onSecondary: Color(0xff121a1f),
      secondaryContainer: Color(0xff232c30),
      onSecondaryContainer: Color(0xffe8ecea),
      tertiary: Color(0xfff0a06a),
      onTertiary: Color(0xff2b1407),
      tertiaryContainer: Color(0xff3a2619),
      onTertiaryContainer: Color(0xfff7c9a6),
      error: Color(0xfff2b8b5),
      onError: Color(0xff601410),
      errorContainer: Color(0xff8c1d18),
      onErrorContainer: Color(0xfff9dedc),
      surface: Color(0xff182023),
      onSurface: Color(0xffe8ecea),
      onSurfaceVariant: Color(0xff9aa6a3),
      surfaceContainerLowest: Color(0xff0f1416),
      surfaceContainerLow: Color(0xff182023),
      surfaceContainer: Color(0xff1c2528),
      surfaceContainerHigh: Color(0xff232c30),
      surfaceContainerHighest: Color(0xff2b3539),
      outline: Color(0xff3c484c),
      outlineVariant: Color(0xff263034),
      inverseSurface: Color(0xffe8ecea),
      onInverseSurface: Color(0xff1e272b),
      inversePrimary: Color(0xff0e6e66),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
    );
  }

  static TextTheme _text(ColorScheme scheme) {
    TextStyle display(double size, FontWeight weight, {double spacing = 0}) =>
        TextStyle(
          fontFamily: displayFont,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: scheme.onSurface,
          fontFeatures: tabular,
        );
    TextStyle body(double size, FontWeight weight, double height) => TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: scheme.onSurface,
      fontFeatures: tabular,
    );
    return TextTheme(
      displayLarge: display(48, FontWeight.w800, spacing: -1.2),
      displayMedium: display(40, FontWeight.w800, spacing: -1),
      displaySmall: display(34, FontWeight.w800, spacing: -.8),
      headlineLarge: display(30, FontWeight.w800, spacing: -.6),
      headlineMedium: display(26, FontWeight.w800, spacing: -.5),
      headlineSmall: display(22, FontWeight.w800, spacing: -.3),
      titleLarge: display(19, FontWeight.w700),
      titleMedium: display(16, FontWeight.w700),
      titleSmall: body(14, FontWeight.w600, 1.35),
      bodyLarge: body(16, FontWeight.w400, 1.45),
      bodyMedium: body(14, FontWeight.w400, 1.45),
      bodySmall: body(
        12,
        FontWeight.w400,
        1.35,
      ).copyWith(color: scheme.onSurfaceVariant),
      labelLarge: body(14, FontWeight.w600, 1.3),
      labelMedium: body(12, FontWeight.w600, 1.3),
      labelSmall: body(11, FontWeight.w600, 1.3).copyWith(letterSpacing: .4),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = _scheme(brightness);
    final wealth = brightness == Brightness.light
        ? WealthColors.light
        : WealthColors.dark;
    final text = _text(scheme);
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusControl),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusCard),
      side: BorderSide(color: wealth.border),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: bodyFont,
      textTheme: text,
      extensions: [wealth],
      scaffoldBackgroundColor: wealth.ground,
      canvasColor: wealth.ground,
      dividerTheme: DividerThemeData(color: wealth.border, space: 1),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: wealth.ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        foregroundColor: scheme.onSurface,
      ),
      listTileTheme: ListTileThemeData(
        shape: controlShape,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.secondary),
        selectedLabelTextStyle: text.labelLarge?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        unselectedLabelTextStyle: text.labelLarge?.copyWith(
          color: scheme.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            letterSpacing: 0,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.secondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.secondary,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: wealth.border,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: text.labelLarge,
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: text.labelLarge,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          textStyle: text.labelLarge,
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: scheme.outline)),
        side: BorderSide(color: scheme.outline),
        labelStyle: text.labelMedium,
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: text.labelMedium,
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outline),
          shape: controlShape,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: text.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: BorderSide(color: wealth.border),
        ),
        textStyle: text.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusControl),
              side: BorderSide(color: wealth.border),
            ),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

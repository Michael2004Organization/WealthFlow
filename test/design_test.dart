import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/app/app_theme.dart';
import 'package:wealthflow/app/design.dart';

void main() {
  group('DesignChoice', () {
    test('reads stored values', () {
      expect(
        DesignChoice.parse('bento'),
        const DesignChoice(AppDesign.bento, ThemeMode.dark),
      );
      expect(
        DesignChoice.parse('terminal'),
        const DesignChoice(AppDesign.terminal, ThemeMode.dark),
      );
      expect(
        DesignChoice.parse('light'),
        const DesignChoice(AppDesign.classic, ThemeMode.light),
      );
      expect(
        DesignChoice.parse('dark'),
        const DesignChoice(AppDesign.classic, ThemeMode.dark),
      );
    });

    test('unknown or missing values fall back to classic/system', () {
      for (final value in [null, '', 'system', 'neon']) {
        expect(
          DesignChoice.parse(value),
          const DesignChoice(AppDesign.classic, ThemeMode.system),
        );
      }
    });

    test('every choice round-trips through its stored value', () {
      for (final choice in DesignChoice.all) {
        expect(DesignChoice.parse(choice.storedValue), choice);
      }
    });
  });

  group('AppTheme', () {
    test('Bento and Terminal are dark, even as the light theme', () {
      for (final design in [AppDesign.bento, AppDesign.terminal]) {
        expect(AppTheme.light(design).brightness, Brightness.dark);
        expect(AppTheme.dark(design).brightness, Brightness.dark);
      }
      expect(AppTheme.light().brightness, Brightness.light);
    });

    test('each theme carries its colors and style', () {
      final terminal = AppTheme.dark(AppDesign.terminal);
      expect(terminal.extension<WealthColors>(), WealthColors.terminal);
      expect(terminal.extension<DesignStyle>(), DesignStyle.terminal);
      expect(
        terminal.textTheme.headlineSmall?.fontFamily,
        DesignStyle.terminal.displayFont,
      );

      final bento = AppTheme.dark(AppDesign.bento);
      expect(bento.extension<WealthColors>(), WealthColors.bento);
      expect(bento.extension<DesignStyle>()!.outlinedCards, isFalse);

      expect(AppTheme.light().extension<WealthColors>(), WealthColors.light);
    });
  });
}

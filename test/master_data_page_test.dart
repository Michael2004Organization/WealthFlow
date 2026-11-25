import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/app/app_theme.dart';
import 'package:wealthflow/app/design.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/features/settings/master_data_page.dart';
import 'package:wealthflow_core/database/app_database.dart';

final _created = DateTime.utc(2026, 11, 1);

MasterDataData _item(String kind, String value) => MasterDataData(
  id: '$kind-$value',
  userId: 'owner',
  kind: kind,
  value: value,
  createdAt: _created,
);

Future<void> _pump(
  WidgetTester tester,
  Size size,
  AppDesign design, {
  bool admin = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('owner'),
        isAdminProvider.overrideWithValue(admin),
        countryTaxRatesProvider.overrideWith(
          (ref) => Stream.value([
            CountryTaxRate(
              country: 'Schweiz',
              withholdingTaxRate: 30,
              currency: 'CHF',
              exchangeRate: 1,
              updatedAt: _created,
            ),
          ]),
        ),
        masterDataProvider.overrideWith(
          (ref) => Stream.value([
            _item('category', 'Lebensmittel'),
            _item('category', 'Auto'),
            _item('merchant', 'Rewe'),
            _item('country', 'USA'),
            _item('country', 'Schweiz'),
            _item('country', 'Atlantis'),
          ]),
        ),
        assetClassesProvider.overrideWith((ref) => Stream.value(const [])),
        masterDataUsageProvider.overrideWith(
          (ref) async => {
            'category': {
              'Lebensmittel': const MasterDataUsage(household: 12),
              'Kino': const MasterDataUsage(household: 2),
            },
          },
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(design),
        home: const Scaffold(body: MasterDataPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final design in AppDesign.values) {
    for (final size in const [Size(390, 844), Size(1280, 800)]) {
      testWidgets('builds in ${design.name} at ${size.width.toInt()} px', (
        tester,
      ) async {
        await _pump(tester, size, design);
        expect(tester.takeException(), isNull);
        expect(find.text('Lebensmittel'), findsOneWidget);
        expect(find.text('in 12 Einträgen'), findsOneWidget);
        expect(find.text('Auto'), findsOneWidget);
        expect(find.text('nicht verwendet'), findsOneWidget);
        // Used in bookings but missing from the list, below the entries.
        await tester.scrollUntilVisible(
          find.text('Kino'),
          120,
          scrollable: find
              .byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
              )
              .last,
        );
        expect(find.text('Kino'), findsOneWidget);
        expect(find.text('Übernehmen'), findsOneWidget);
      });
    }
  }

  testWidgets('switches kind and filters by search', (tester) async {
    await _pump(tester, const Size(1280, 800), AppDesign.classic);
    await tester.tap(find.text('Händler & Quellen'));
    await tester.pumpAndSettle();
    expect(find.text('Rewe'), findsOneWidget);
    expect(find.text('Lebensmittel'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Suchen'), 'xyz');
    await tester.pumpAndSettle();
    expect(find.text('Rewe'), findsNothing);
    expect(find.textContaining('Nichts gefunden'), findsOneWidget);
  });

  testWidgets('suggestion chips add common values', (tester) async {
    await _pump(tester, const Size(1280, 800), AppDesign.classic);
    // Known values are not suggested again.
    expect(find.widgetWithText(ActionChip, 'Lebensmittel'), findsNothing);
    expect(find.widgetWithText(ActionChip, 'Wohnen'), findsOneWidget);
  });

  for (final admin in [true, false]) {
    testWidgets('countries show tax facts (admin: $admin)', (tester) async {
      await _pump(tester, const Size(1280, 900), AppDesign.bento, admin: admin);
      await tester.tap(find.text('Länder'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      Finder fact(String text) => find.text(text, findRichText: true);
      // USA: standard value from the BZSt table.
      expect(fact('Quellensteuer 15 %'), findsOneWidget);
      expect(fact('Standardwert'), findsOneWidget);
      // Schweiz: stored 30 % differs from the standard 35 %, 15 % creditable.
      expect(fact('Quellensteuer 30 %'), findsOneWidget);
      expect(fact('eigener Wert'), findsOneWidget);
      expect(fact('anrechenbar 15 %'), findsNWidgets(2));
      // Unknown country.
      expect(fact('Quellensteuer unbekannt'), findsOneWidget);
      expect(find.textContaining('Bundeszentralamt'), findsOneWidget);
      // Only administrators get the shortcut to store standard values.
      expect(
        find.textContaining('Standardwerte des BZSt übernehmen'),
        admin ? findsOneWidget : findsNothing,
      );
      expect(
        find.textContaining('Steuersätze ändert ein Administrator'),
        admin ? findsNothing : findsOneWidget,
      );
    });
  }

  testWidgets('tax dialog offers the standard value', (tester) async {
    await _pump(tester, const Size(1280, 900), AppDesign.classic);
    await tester.tap(find.text('Länder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schweiz'));
    await tester.pumpAndSettle();
    expect(find.text('Steuern · Schweiz'), findsOneWidget);
    expect(find.textContaining('Standard: 35 % einbehalten'), findsOneWidget);
    await tester.tap(find.text('Standardwert einsetzen'));
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '35'), findsOneWidget);
  });
}

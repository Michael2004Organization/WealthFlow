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

Future<void> _pump(WidgetTester tester, Size size, AppDesign design) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('owner'),
        masterDataProvider.overrideWith(
          (ref) => Stream.value([
            _item('category', 'Lebensmittel'),
            _item('category', 'Auto'),
            _item('merchant', 'Rewe'),
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
        // Used in bookings but missing from the list.
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
}

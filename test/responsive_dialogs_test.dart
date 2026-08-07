import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/database/app_database.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/features/auth/auth_page.dart';
import 'package:wealthflow/features/calculators/calculators_page.dart';
import 'package:wealthflow/features/finance/accounts_page.dart';
import 'package:wealthflow/features/finance/investments_page.dart';
import 'package:wealthflow/features/household/household_page.dart';
import 'package:wealthflow/features/vehicles/vehicles_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppDatabase> pumpPage(
    WidgetTester tester,
    Widget page, {
    required List<Override> overrides,
    Size size = const Size(360, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentUserIdProvider.overrideWithValue('responsive-user'),
          ...overrides,
        ],
        child: MaterialApp(home: Scaffold(body: page)),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  testWidgets('account editor fits a narrow mobile viewport', (tester) async {
    await pumpPage(
      tester,
      const AccountsPage(),
      overrides: [
        accountsProvider.overrideWith((_) => Stream.value(const <Account>[])),
      ],
    );

    await tester.tap(find.text('Konto').first);
    await tester.pumpAndSettle();

    expect(find.text('Konto anlegen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vehicle editor fits a narrow mobile viewport', (tester) async {
    await pumpPage(
      tester,
      const VehiclesPage(),
      overrides: [
        vehiclesProvider.overrideWith((_) => Stream.value(const <Vehicle>[])),
        vehicleCostsProvider.overrideWith(
          (_) => Stream.value(const <VehicleCost>[]),
        ),
      ],
    );

    await tester.tap(find.text('Fahrzeug').first);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Fahrzeug anlegen'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('browser login fills a wide viewport without layout errors', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const AuthPage(),
      size: const Size(1024, 630),
      overrides: const [],
    );

    expect(find.text('Willkommen zurück'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('investment editor stacks fields on a narrow viewport', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const InvestmentsPage(),
      overrides: [
        investmentsProvider.overrideWith(
          (_) => Stream.value(const <Investment>[]),
        ),
        masterDataProvider.overrideWith(
          (_) => Stream.value(const <MasterDataData>[]),
        ),
        stockMastersProvider.overrideWith(
          (_) => Stream.value(const <StockMaster>[]),
        ),
      ],
    );

    await tester.tap(find.text('Position').first);
    await tester.pumpAndSettle();

    expect(find.text('Position anlegen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all calculator tabs fit a narrow viewport', (tester) async {
    await pumpPage(
      tester,
      const CalculatorsPage(),
      overrides: [
        investmentsProvider.overrideWith(
          (_) => Stream.value(const <Investment>[]),
        ),
        preferencesProvider.overrideWith((_) => Stream.value(null)),
        accountsProvider.overrideWith((_) => Stream.value(const <Account>[])),
        ledgerEntriesProvider.overrideWith(
          (_) => Stream.value(const <LedgerEntry>[]),
        ),
      ],
    );

    for (final tab in ['Entnahme', 'Spritkosten', 'Freiheit', 'Kontoziel']) {
      final finder = find.text(tab);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Tab $tab');
    }
  });

  testWidgets('monthly household booking fits a narrow dialog', (tester) async {
    final now = DateTime.now();
    final account = Account(
      id: 'giro',
      userId: 'responsive-user',
      bankName: 'Testbank',
      label: 'Haushaltskonto mit langem Namen',
      holder: '',
      iban: '',
      bic: '',
      accountNumber: '',
      currency: 'EUR',
      balance: 1234.56,
      availableBalance: 1234.56,
      notes: '',
      createdAt: now,
      updatedAt: now,
    );
    await pumpPage(
      tester,
      const HouseholdPage(),
      overrides: [
        accountsProvider.overrideWith((_) => Stream.value([account])),
        ledgerEntriesProvider.overrideWith(
          (_) => Stream.value(const <LedgerEntry>[]),
        ),
        vehiclesProvider.overrideWith((_) => Stream.value(const <Vehicle>[])),
        masterDataProvider.overrideWith(
          (_) => Stream.value(const <MasterDataData>[]),
        ),
        preferencesProvider.overrideWith((_) => const Stream.empty()),
      ],
    );

    await tester.tap(find.text('Buchung').first);
    await tester.pumpAndSettle();
    final recurring = find.text('Automatisch monatlich buchen');
    await tester.ensureVisible(recurring);
    await tester.tap(recurring);
    await tester.pumpAndSettle();

    expect(find.text('Laufzeit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

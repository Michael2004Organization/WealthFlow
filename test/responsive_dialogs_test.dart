import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/features/auth/auth_page.dart';
import 'package:wealthflow/features/calculators/calculators_page.dart';
import 'package:wealthflow/features/finance/accounts_page.dart';
import 'package:wealthflow/features/finance/dividend_prompt.dart';
import 'package:wealthflow/features/finance/investments_page.dart';
import 'package:wealthflow/features/household/bank_import_page.dart';
import 'package:wealthflow/features/household/budgets_page.dart';
import 'package:wealthflow/features/household/household_page.dart';
import 'package:wealthflow/features/household/standing_orders_page.dart';
import 'package:wealthflow/features/settings/administration_page.dart';
import 'package:wealthflow/features/vehicles/vehicles_page.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/bank_csv.dart';
import 'package:wealthflow_core/finance/dividend_math.dart';
import 'package:wealthflow_core/finance/dividend_projection.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  for (final size in [const Size(360, 800), const Size(1920, 1080)]) {
    testWidgets('tax country dialog supports mouse input at $size', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const AdministrationPage(),
        size: size,
        overrides: [
          isAdminProvider.overrideWithValue(true),
          usersProvider.overrideWith((_) => Stream.value(const <User>[])),
          stockMastersProvider.overrideWith(
            (_) => Stream.value(const <StockMaster>[]),
          ),
          countryTaxRatesProvider.overrideWith(
            (_) => Stream.value(const <CountryTaxRate>[]),
          ),
          appConfigurationProvider.overrideWith((_) => const Stream.empty()),
          preferencesProvider.overrideWith((_) => Stream.value(null)),
          assetClassesProvider.overrideWith(
            (_) => Stream.value(const <AssetClassesData>[]),
          ),
          errorLogsProvider.overrideWith(
            (_) => Stream.value(const <AppErrorLog>[]),
          ),
        ],
      );
      final tab = find.text('Steuern');
      await tester.ensureVisible(tab);
      await tester.tap(tab);
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: size.center(Offset.zero));
      addTearDown(mouse.removePointer);
      await tester.tap(find.text('Land hinzufügen'));
      await tester.pumpAndSettle();
      expect(find.text('Steuerland hinzufügen'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final currency = find.descendant(
        of: find.byType(DropdownMenu<String>),
        matching: find.byType(TextField),
      );
      await mouse.moveTo(tester.getCenter(currency));
      await tester.tap(currency);
      await tester.enterText(currency, 'US');
      await tester.pumpAndSettle();
      await tester.tap(find.text('USD').hitTestable());
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(currency).controller!.text, 'USD');
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      await mouse.moveTo(const Offset(10, 10));
      await tester.pump();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('account editor fits a narrow mobile viewport', (tester) async {
    await pumpPage(
      tester,
      const AccountsPage(),
      overrides: [
        accountsProvider.overrideWith((_) => Stream.value(const <Account>[])),
        accountBalanceHistoriesProvider.overrideWith(
          (_) => Stream.value(const <AccountBalanceHistory>[]),
        ),
        ledgerEntriesProvider.overrideWith(
          (_) => Stream.value(const <LedgerEntry>[]),
        ),
        allInvestmentsProvider.overrideWith(
          (_) => Stream.value(const <Investment>[]),
        ),
        investmentPurchasesProvider.overrideWith(
          (_) => Stream.value(const <InvestmentPurchase>[]),
        ),
        portfolioSalesProvider.overrideWith(
          (_) => Stream.value(const <PortfolioSale>[]),
        ),
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
    final now = DateTime.now();
    final account = Account(
      id: 'portfolio-account',
      userId: 'responsive-user',
      bankName: 'Testbank',
      label: 'Portfolio',
      holder: '',
      iban: '',
      bic: '',
      accountNumber: '',
      currency: 'EUR',
      balance: 0,
      availableBalance: 0,
      usageType: 'portfolio',
      notes: '',
      displayOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
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
        countryTaxRatesProvider.overrideWith(
          (_) => Stream.value(const <CountryTaxRate>[]),
        ),
        assetClassesProvider.overrideWith(
          (_) => Stream.value(const <AssetClassesData>[]),
        ),
        isAdminProvider.overrideWithValue(false),
        accountsProvider.overrideWith((_) => Stream.value([account])),
        accountBalanceHistoriesProvider.overrideWith(
          (_) => Stream.value(const <AccountBalanceHistory>[]),
        ),
        ledgerEntriesProvider.overrideWith(
          (_) => Stream.value(const <LedgerEntry>[]),
        ),
        physicalAssetsProvider.overrideWith(
          (_) => Stream.value(const <PhysicalAsset>[]),
        ),
        investmentPurchasesProvider.overrideWith(
          (_) => Stream.value(const <InvestmentPurchase>[]),
        ),
        portfolioSalesProvider.overrideWith(
          (_) => Stream.value(const <PortfolioSale>[]),
        ),
        portfolioAuditLogsProvider.overrideWith(
          (_) => Stream.value(const <PortfolioAuditLog>[]),
        ),
        dividendSchedulesProvider.overrideWith(
          (_) => Stream.value(const <DividendSchedule>[]),
        ),
        preferencesProvider.overrideWith((_) => Stream.value(null)),
      ],
    );

    await tester.tap(find.text('Anlage').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    expect(find.text('Position anlegen'), findsOneWidget);
    expect(find.byTooltip('Anlageklasse auswählen'), findsOneWidget);
    final assetTypeDropdown = find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(DropdownMenu<String>),
        )
        .first;
    await tester.ensureVisible(assetTypeDropdown);
    await tester.tap(assetTypeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kryptowährung').last);
    await tester.pumpAndSettle();
    expect(find.text('ISIN'), findsNothing);
    expect(find.textContaining('Symbol'), findsWidgets);
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

  for (final size in [const Size(360, 800), const Size(1920, 1080)]) {
    testWidgets('monthly household booking fits the entry editor at $size', (
      tester,
    ) async {
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
        usageType: 'household',
        notes: '',
        displayOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      await pumpPage(
        tester,
        const _NewBookingHost(),
        overrides: [
          accountsProvider.overrideWith((_) => Stream.value([account])),
          accountBalanceHistoriesProvider.overrideWith(
            (_) => Stream.value(const <AccountBalanceHistory>[]),
          ),
          ledgerEntriesProvider.overrideWith(
            (_) => Stream.value(const <LedgerEntry>[]),
          ),
          allInvestmentsProvider.overrideWith(
            (_) => Stream.value(const <Investment>[]),
          ),
          investmentPurchasesProvider.overrideWith(
            (_) => Stream.value(const <InvestmentPurchase>[]),
          ),
          portfolioSalesProvider.overrideWith(
            (_) => Stream.value(const <PortfolioSale>[]),
          ),
          physicalAssetsProvider.overrideWith(
            (_) => Stream.value(const <PhysicalAsset>[]),
          ),
          vehiclesProvider.overrideWith((_) => Stream.value(const <Vehicle>[])),
          masterDataProvider.overrideWith(
            (_) => Stream.value(const <MasterDataData>[]),
          ),
          preferencesProvider.overrideWith((_) => const Stream.empty()),
        ],
        size: size,
      );

      await tester.tap(find.byIcon(Icons.add_circle_rounded));
      await tester.pumpAndSettle();
      for (final kind in ['Ausgabe', 'Einnahme', 'Umbuchung', 'Sparen']) {
        expect(find.text(kind), findsOneWidget);
      }
      final options = find.text('Weitere Optionen');
      await tester.ensureVisible(options);
      await tester.tap(options);
      await tester.pumpAndSettle();
      final recurring = find.text('Mehrere Monate buchen');
      await tester.ensureVisible(recurring);
      await tester.tap(recurring);
      await tester.pumpAndSettle();

      expect(find.text('Laufzeit (Monate)'), findsOneWidget);
      // Phones get a bottom sheet, larger screens a dialog.
      expect(
        find.byType(size.width < 600 ? BottomSheet : Dialog),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(360, 800), const Size(1920, 1080)]) {
    testWidgets('standing order editor fits at $size', (tester) async {
      final now = DateTime.now();
      Account account(String id) => Account(
        id: id,
        userId: 'responsive-user',
        bankName: 'Testbank',
        label: 'Konto $id mit langem Namen',
        holder: '',
        iban: '',
        bic: '',
        accountNumber: '',
        currency: 'EUR',
        balance: 1234.56,
        availableBalance: 1234.56,
        usageType: 'household',
        notes: '',
        displayOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      await pumpPage(
        tester,
        const StandingOrdersPage(),
        overrides: [
          accountsProvider.overrideWith(
            (_) => Stream.value([account('giro'), account('spar')]),
          ),
          standingOrdersProvider.overrideWith(
            (_) => Stream.value(const <StandingOrder>[]),
          ),
          allInvestmentsProvider.overrideWith(
            (_) => Stream.value(const <Investment>[]),
          ),
          physicalAssetsProvider.overrideWith(
            (_) => Stream.value(const <PhysicalAsset>[]),
          ),
          preferencesProvider.overrideWith((_) => const Stream.empty()),
        ],
        size: size,
      );

      await tester.tap(find.text('Dauerauftrag anlegen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sparen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vierteljährlich'));
      await tester.pumpAndSettle();

      expect(find.text('Zielkonto / Investkonto *'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('budget editor fits a phone', (tester) async {
    final now = DateTime.now();
    LedgerEntry expense(String category, int day) => LedgerEntry(
      id: '$category-$day',
      userId: 'responsive-user',
      bookingDate: DateTime(now.year, now.month - 1, day),
      amount: 87.4,
      isIncome: false,
      category: category,
      merchant: '',
      description: '',
      paymentMethod: '',
      recurrenceId: '',
      sourceType: 'manual',
      sourceId: '',
      vehicleId: '',
      accountId: 'giro',
      accountApplied: true,
      createdAt: now,
      updatedAt: now,
    );
    await pumpPage(
      tester,
      const BudgetsPage(),
      overrides: [
        categoryBudgetsProvider.overrideWith(
          (_) => Stream.value(const <CategoryBudget>[]),
        ),
        ledgerEntriesProvider.overrideWith(
          (_) => Stream.value([
            for (final category in [
              'Lebensmittel',
              'Freizeit',
              'Restaurant und Lieferdienste',
              'Drogerie',
            ])
              expense(category, 3),
          ]),
        ),
      ],
    );

    await tester.tap(find.text('Budget festlegen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lebensmittel'));
    await tester.pumpAndSettle();

    // Suggests a round amount above last months' average.
    expect(find.text('30,00'), findsOneWidget);
    expect(find.text('Rest übertragen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final csv in [
    'Buchungstag;Beguenstigter/Zahlungspflichtiger;Verwendungszweck;Betrag\n'
        '03.11.2026;Ein sehr langer Händlername mit Filialnummer 1234;'
        'Kartenzahlung;-42,17\n',
    'Tag;Wert;Wer\n2026-10-01;12,50;Firma\n',
  ]) {
    testWidgets('bank import preview fits a phone: ${csv.split(';').first}', (
      tester,
    ) async {
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
        balance: 0,
        availableBalance: 0,
        usageType: 'household',
        notes: '',
        displayOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      await pumpPage(
        tester,
        Dialog.fullscreen(
          child: BankImportDialog(
            userId: 'responsive-user',
            table: parseBankCsv(csv.codeUnits),
            accounts: [account],
            initialAccountId: 'giro',
            existing: const [],
          ),
        ),
        overrides: const [],
      );

      expect(find.textContaining('übernehmen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dividend prompt fits a phone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.now();
    final store = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(store.close);
    await store
        .into(store.investments)
        .insert(
          InvestmentsCompanion.insert(
            id: 'etf',
            userId: 'responsive-user',
            name: 'Vanguard FTSE All-World High Dividend Yield UCITS ETF',
            assetType: 'ETF',
            purchaseDate: now,
            purchasePrice: 100,
            quantity: 10,
            currentPrice: 100,
            createdAt: now,
            updatedAt: now,
          ),
        );
    final investment = await store.select(store.investments).getSingle();
    const tax = DividendTaxResult(
      grossSource: 50,
      withholdingTaxSource: 0,
      gross: 50,
      withholdingTax: 0,
      creditableWithholdingTax: 0,
      germanCapitalTax: 7.9,
      solidaritySurcharge: 0,
      churchTax: 0,
      allowanceUsed: 0,
      allowanceRemaining: 0,
      net: 42.1,
    );
    await pumpPage(
      tester,
      SingleChildScrollView(
        child: DividendPromptCard(
          pending: [
            for (final known in [true, false])
              ProjectedDividend(
                investment: investment,
                month: now.month,
                tax: tax,
                withholdingTaxRate: 0,
                date: DateTime(now.year, now.month, 1),
                paymentDateKnown: known,
                sourceCurrency: 'EUR',
                exchangeRate: 1,
                grossSource: 50,
                accountCurrency: 'EUR',
              ),
          ],
        ),
      ),
      overrides: [dividendAutoBookProvider.overrideWith((_) async => false)],
    );

    expect(find.text('2 Dividenden eingegangen?'), findsOneWidget);
    expect(find.text('Übernehmen'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}

/// Stands in for the "+" of the app's navigation bar, which opens the
/// booking editor on phones where the household page has no own button.
class _NewBookingHost extends StatelessWidget {
  const _NewBookingHost();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Expanded(child: HouseholdPage()),
      Consumer(
        builder: (context, ref, _) => IconButton(
          onPressed: () => startNewBooking(context, ref),
          icon: const Icon(Icons.add_circle_rounded),
        ),
      ),
    ],
  );
}

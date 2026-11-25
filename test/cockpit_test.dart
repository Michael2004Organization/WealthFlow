import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/app/app_theme.dart';
import 'package:wealthflow/app/design.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/features/dashboard/cockpit.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/category_budget.dart';
import 'package:wealthflow_core/finance/free_to_spend.dart';

final _created = DateTime(2026, 1, 1);

BudgetProgress _budget(String category, double limit, double spent) =>
    BudgetProgress(
      budget: CategoryBudget(
        id: category,
        userId: 'user',
        category: category,
        monthlyLimit: limit,
        carryOver: false,
        startMonth: DateTime(2026, 1),
        createdAt: _created,
        updatedAt: _created,
      ),
      spent: spent,
      carried: 0,
    );

LedgerEntry _entry(String merchant, double amount, {bool income = false}) =>
    LedgerEntry(
      id: merchant,
      userId: 'user',
      bookingDate: DateTime(2026, 11, 24),
      amount: amount,
      isIncome: income,
      category: income ? 'Gehalt' : 'Lebensmittel',
      merchant: merchant,
      description: '',
      paymentMethod: '',
      recurrenceId: '',
      sourceType: 'manual',
      sourceId: '',
      vehicleId: '',
      accountId: '',
      accountApplied: false,
      createdAt: _created,
      updatedAt: _created,
    );

final _data = CockpitData(
  free: calculateFreeToSpend(
    balance: 2078.40,
    plannedExpenses: 894,
    budgets: [_budget('Lebensmittel', 450, 312), _budget('Freizeit', 150, 188)],
    today: DateTime(2026, 11, 25),
  ),
  netWorth: 41920.18,
  netWorthChange: 982,
  netWorthHistory: const [40100, 40400, 40300, 41000, 41500, 41920.18],
  income: 3250,
  expenses: 2065,
  cashflow: const [
    CockpitMonth('Jun', 3200, 2100),
    CockpitMonth('Jul', 3200, 2400),
    CockpitMonth('Aug', 3250, 1900),
    CockpitMonth('Sep', 3200, 2300),
    CockpitMonth('Okt', 3600, 2250),
    CockpitMonth('Nov', 3250, 2065),
  ],
  due: [
    CockpitDue(
      date: DateTime(2026, 12, 1),
      title: 'Miete',
      amount: 820,
      income: false,
    ),
    CockpitDue(
      date: DateTime(2026, 12, 5),
      title: 'Dividende Allianz',
      amount: 48.6,
      income: true,
    ),
  ],
  budgets: [_budget('Lebensmittel', 450, 312), _budget('Freizeit', 150, 188)],
  recent: [_entry('Rewe', 54.2), _entry('Arbeitgeber', 3250, income: true)],
  review: [CockpitReview('2 Dividenden bestätigen', (_) {})],
  security: CockpitSecurity(
    appLock: true,
    lockAfter: const Duration(seconds: 30),
    lastBackup: DateTime.now(),
    backupFailed: false,
    serverConnected: false,
  ),
);

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Size size,
  AppDesign design,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      masterDataProvider.overrideWith(
        (ref) => Stream.value(const <MasterDataData>[]),
      ),
      ledgerEntriesProvider.overrideWith(
        (ref) => Stream.value(const <LedgerEntry>[]),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.dark(design),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Cockpit(data: _data),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  for (final design in AppDesign.values) {
    for (final size in const [Size(390, 844), Size(1440, 900)]) {
      testWidgets('${design.name} cockpit at ${size.width.toInt()} px', (
        tester,
      ) async {
        await _pump(tester, size, design);
        expect(tester.takeException(), isNull);
        // 2078,40 − 894 − (138 open food budget) = 1046,40.
        expect(find.textContaining('1.046,40'), findsOneWidget);
        // Terminal writes labels in capitals.
        expect(
          find.textContaining(
            RegExp('frei bis 30\\. november', caseSensitive: false),
          ),
          findsOneWidget,
        );
        expect(find.text('2 Dividenden bestätigen'), findsOneWidget);
        expect(find.byType(QuickEntryField), findsOneWidget);
      });
    }
  }

  testWidgets('privacy mode hides the amounts', (tester) async {
    final container = await _pump(
      tester,
      const Size(1440, 900),
      AppDesign.bento,
    );
    expect(find.textContaining('1.046,40'), findsOneWidget);
    expect(find.text('Miete'), findsOneWidget);

    container.read(privacyModeProvider.notifier).state = true;
    await tester.pumpAndSettle();
    expect(find.textContaining('1.046,40'), findsNothing);
    expect(find.textContaining('41.920'), findsNothing);
    expect(find.textContaining('820'), findsNothing);
    expect(find.text('•••• €'), findsWidgets);
    expect(find.text('Ausgeblendet'), findsOneWidget);
  });

  testWidgets('quick entry shows a preview while typing', (tester) async {
    await _pump(tester, const Size(1440, 900), AppDesign.terminal);
    await tester.enterText(find.byType(TextField), '12,50 Bäcker bar');
    await tester.pump();
    expect(find.textContaining('Ausgabe · Bäcker · Sonstiges · Bar'), findsOne);
  });
}

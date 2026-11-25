import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/category_budget.dart';
import 'package:wealthflow_core/finance/free_to_spend.dart';
import 'package:wealthflow_core/finance/quick_entry.dart';

final _created = DateTime(2026, 1, 1);

BudgetProgress _budget(double limit, double spent) => BudgetProgress(
  budget: CategoryBudget(
    id: '$limit',
    userId: 'user',
    category: 'Kategorie $limit',
    monthlyLimit: limit,
    carryOver: false,
    startMonth: DateTime(2026, 1),
    createdAt: _created,
    updatedAt: _created,
  ),
  spent: spent,
  carried: 0,
);

LedgerEntry _entry(String merchant, String category, DateTime date) =>
    LedgerEntry(
      id: '$merchant-$date',
      userId: 'user',
      bookingDate: date,
      amount: 10,
      isIncome: false,
      category: category,
      merchant: merchant,
      description: '',
      paymentMethod: 'Bar',
      recurrenceId: '',
      sourceType: 'manual',
      sourceId: '',
      vehicleId: '',
      accountId: '',
      accountApplied: false,
      createdAt: date,
      updatedAt: date,
    );

void main() {
  group('Frei bis Monatsende', () {
    test('balance minus planned expenses minus open budgets', () {
      final free = calculateFreeToSpend(
        balance: 2078.40,
        plannedExpenses: 894,
        budgets: [_budget(450, 312), _budget(200, 96)],
        today: DateTime(2026, 11, 25),
      );
      // Open budget rest: 138 + 104 = 242.
      expect(free.reserved, 242);
      expect(free.free, closeTo(942.40, 1e-9));
      expect(free.daysLeft, 6);
      expect(free.perDay, closeTo(157.07, .01));
      expect(free.budgetUse, closeTo(408 / 650, 1e-9));
    });

    test('an overspent budget reserves nothing', () {
      final free = calculateFreeToSpend(
        balance: 500,
        plannedExpenses: 0,
        budgets: [_budget(150, 188)],
        today: DateTime(2026, 11, 30),
      );
      expect(free.reserved, 0);
      expect(free.free, 500);
      expect(free.daysLeft, 1);
      expect(free.budgetUse, greaterThan(1));
    });

    test('never a negative amount per day', () {
      final free = calculateFreeToSpend(
        balance: 100,
        plannedExpenses: 800,
        budgets: const [],
        today: DateTime(2026, 2, 1),
      );
      expect(free.free, -700);
      expect(free.perDay, 0);
      expect(free.budgetUse, isNull);
      expect(free.monthProgress, 0);
    });
  });

  group('Schnelleingabe', () {
    final today = DateTime(2026, 11, 25, 14);

    test('reads amount, merchant and payment method', () {
      final entry = parseQuickEntry(
        '12,50 Bäcker bar',
        today: today,
        paymentMethods: ['Bar', 'Karte'],
        categories: ['Lebensmittel'],
      )!;
      expect(entry.amount, 12.5);
      expect(entry.income, isFalse);
      expect(entry.merchant, 'Bäcker');
      expect(entry.paymentMethod, 'Bar');
      expect(entry.category, 'Sonstiges');
      expect(entry.date, DateTime(2026, 11, 25));
    });

    test('learns the category from earlier bookings at the merchant', () {
      final entry = parseQuickEntry(
        '54.20 tankstelle',
        today: today,
        history: [
          _entry('Tankstelle', 'Freizeit', DateTime(2026, 9, 1)),
          _entry('Tankstelle', 'Auto', DateTime(2026, 11, 1)),
        ],
      )!;
      expect(entry.amount, 54.2);
      expect(entry.category, 'Auto');
      expect(entry.categoryLearned, isTrue);
      expect(entry.paymentMethod, 'Bar');
    });

    test('income, category word, thousands and dates', () {
      final entry = parseQuickEntry(
        '+3.250 Gehalt gestern kk',
        today: today,
        categories: ['Gehalt'],
        paymentMethods: ['Kreditkarte'],
      )!;
      expect(entry.amount, 3250);
      expect(entry.income, isTrue);
      expect(entry.category, 'Gehalt');
      expect(entry.merchant, '');
      expect(entry.paymentMethod, 'Kreditkarte');
      expect(entry.date, DateTime(2026, 11, 24));
      expect(entry.summary, 'Einnahme · Gehalt · Kreditkarte');
    });

    test('no amount, no booking', () {
      expect(parseQuickEntry('Bäcker bar', today: today), isNull);
      expect(parseQuickEntry('0 Bäcker', today: today), isNull);
      expect(parseQuickEntry('', today: today), isNull);
    });
  });
}

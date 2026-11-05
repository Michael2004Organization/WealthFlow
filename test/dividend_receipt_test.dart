import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/dividend_math.dart';
import 'package:wealthflow_core/finance/dividend_projection.dart';

void main() {
  late AppDatabase database;
  final now = DateTime(2026, 3, 10);

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.createUser(
      UsersCompanion.insert(
        id: 'u',
        email: 'u@example.test',
        displayName: 'u',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.savePreferences(
      UserPreferencesCompanion.insert(userId: 'u', updatedAt: now),
    );
    for (final id in ['depot', 'giro']) {
      await database.saveAccount(
        AccountsCompanion.insert(
          id: id,
          userId: 'u',
          bankName: 'Bank',
          label: id,
          balance: const Value(1000),
          availableBalance: const Value(1000),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    await database.saveInvestment(
      InvestmentsCompanion.insert(
        id: 'apple',
        userId: 'u',
        accountId: const Value('depot'),
        name: 'Apple',
        assetType: 'Aktie',
        purchaseDate: now,
        purchasePrice: 100,
        quantity: 0,
        currentPrice: 100,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() => database.close());

  Future<Investment> apple() => (database.select(
    database.investments,
  )..where((row) => row.id.equals('apple'))).getSingle();

  Future<double> balance(String id) async => (await (database.select(
    database.accounts,
  )..where((row) => row.id.equals(id))).getSingle()).balance;

  Future<List<LedgerEntry>> entries() => (database.select(
    database.ledgerEntries,
  )..where((row) => row.deletedAt.isNull())).get();

  test('auf das Haushaltskonto als Einnahme "Dividende"', () async {
    final investment = await apple();
    await database.receiveDividend(
      userId: 'u',
      investment: investment,
      accountId: 'giro',
      dueDate: DateTime(2026, 2, 15),
      paymentDate: DateTime(2026, 2, 16),
      amount: 42.10,
    );
    // A second confirmation (other device, double tap) books nothing.
    await database.receiveDividend(
      userId: 'u',
      investment: investment,
      accountId: 'giro',
      dueDate: DateTime(2026, 2, 15),
      amount: 42.10,
    );

    final booked = (await entries()).single;
    expect(booked.id, 'div-apple-202602');
    expect(booked.category, 'Dividende');
    expect(booked.isIncome, isTrue);
    expect(booked.merchant, 'Apple');
    expect(booked.bookingDate, DateTime(2026, 2, 16));
    expect(await balance('giro'), closeTo(1042.10, 1e-9));

    await database.undoDividendReceipt('div-apple-202602', 'u');
    expect(await entries(), isEmpty);
    expect(await balance('giro'), closeTo(1000, 1e-9));

    // Confirmed again after the undo.
    await database.receiveDividend(
      userId: 'u',
      investment: investment,
      accountId: 'giro',
      dueDate: DateTime(2026, 2, 15),
      amount: 40,
    );
    expect((await entries()).single.amount, 40);
    expect(await balance('giro'), closeTo(1040, 1e-9));
  });

  test('auf das Depotkonto als Geld im Depot', () async {
    await database.receiveDividend(
      userId: 'u',
      investment: await apple(),
      accountId: 'depot',
      dueDate: DateTime(2026, 2, 15),
      amount: 12.5,
    );
    expect(await entries(), isEmpty);
    expect(await balance('depot'), closeTo(1012.5, 1e-9));

    await database.undoDividendReceipt('div-apple-202602', 'u');
    expect(await balance('depot'), closeTo(1000, 1e-9));
  });

  test('offen sind nur fällige, nicht beantwortete Zahlungen', () async {
    final investment = await apple();
    ProjectedDividend payout(DateTime date, {double net = 10}) =>
        ProjectedDividend(
          investment: investment,
          month: date.month,
          tax: DividendTaxResult(
            grossSource: net,
            withholdingTaxSource: 0,
            gross: net,
            withholdingTax: 0,
            creditableWithholdingTax: 0,
            germanCapitalTax: 0,
            solidaritySurcharge: 0,
            churchTax: 0,
            allowanceUsed: 0,
            allowanceRemaining: 0,
            net: net,
          ),
          withholdingTaxRate: 0,
          date: date,
          paymentDateKnown: true,
          sourceCurrency: 'EUR',
          exchangeRate: 1,
          grossSource: net,
          accountCurrency: 'EUR',
        );
    await database.skipDividend(
      userId: 'u',
      investmentId: 'apple',
      paymentDate: DateTime(2026, 2, 1),
    );
    final receipts = await database.watchDividendReceipts('u').first;

    final pending = pendingDividends(
      [
        payout(DateTime(2026, 3, 20)), // not due yet
        payout(DateTime(2026, 3, 1)),
        payout(DateTime(2026, 2, 3)), // answered: not received
        payout(DateTime(2025, 12, 1)), // too long ago
        payout(DateTime(2026, 3, 5), net: 0),
      ],
      receipts,
      today: DateTime(2026, 3, 10),
    );

    expect(pending.map((item) => item.date), [DateTime(2026, 3, 1)]);
  });
}

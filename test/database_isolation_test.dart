import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('account streams never expose another users data', () async {
    final now = DateTime.utc(2026, 7, 27);
    for (final id in ['alice', 'bob']) {
      await database.createUser(
        UsersCompanion.insert(
          id: id,
          email: '$id@example.test',
          displayName: id,
          passwordHash: 'hash',
          passwordSalt: 'salt',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.savePreferences(
        UserPreferencesCompanion.insert(userId: id, updatedAt: now),
      );
    }
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'alice-account',
        userId: 'alice',
        bankName: 'Bank A',
        label: 'Alice Giro',
        balance: const Value(1200),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'bob-account',
        userId: 'bob',
        bankName: 'Bank B',
        label: 'Bob Giro',
        balance: const Value(9000),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final aliceAccounts = await database.watchAccounts('alice').first;

    expect(aliceAccounts, hasLength(1));
    expect(aliceAccounts.single.id, 'alice-account');
  });

  test('soft-deleted accounts disappear from active streams', () async {
    final now = DateTime.utc(2026, 7, 27);
    await database.createUser(
      UsersCompanion.insert(
        id: 'owner',
        email: 'owner@example.test',
        displayName: 'Owner',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'account',
        userId: 'owner',
        bankName: 'Bank',
        label: 'Giro',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await database.deleteAccount('account', 'owner');

    expect(await database.watchAccounts('owner').first, isEmpty);
  });

  test('monthly ledger series can be stored and removed as one unit', () async {
    final now = DateTime.utc(2026, 7, 28);
    await database.createUser(
      UsersCompanion.insert(
        id: 'series-owner',
        email: 'series@example.test',
        displayName: 'Series',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    for (var month = 8; month <= 10; month++) {
      await database.saveLedgerEntry(
        LedgerEntriesCompanion.insert(
          id: 'salary-$month',
          userId: 'series-owner',
          bookingDate: DateTime.utc(2026, month),
          amount: 3000,
          category: 'Gehalt',
          isIncome: const Value(true),
          recurrenceId: const Value('salary-series'),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    expect(
      await database.watchLedgerEntries('series-owner').first,
      hasLength(3),
    );

    await database.deleteLedgerSeries('salary-series', 'series-owner');

    expect(await database.watchLedgerEntries('series-owner').first, isEmpty);
  });

  test(
    'vehicle costs are mirrored to and removed from the household ledger',
    () async {
      final now = DateTime.utc(2026, 7, 28);
      await database.createUser(
        UsersCompanion.insert(
          id: 'driver',
          email: 'driver@example.test',
          displayName: 'Driver',
          passwordHash: 'hash',
          passwordSalt: 'salt',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveAccount(
        AccountsCompanion.insert(
          id: 'driver-giro',
          userId: 'driver',
          bankName: 'Bank',
          label: 'Haushalt',
          balance: const Value(500),
          availableBalance: const Value(500),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveVehicle(
        VehiclesCompanion.insert(
          id: 'car',
          userId: 'driver',
          vehicleType: 'Auto',
          make: 'Test',
          model: 'Car',
          year: 2024,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await database.saveVehicleCostWithLedger(
        VehicleCostsCompanion.insert(
          id: 'fuel-cost',
          userId: 'driver',
          vehicleId: 'car',
          bookingDate: now,
          category: 'Tanken',
          amount: 75,
          createdAt: now,
          updatedAt: now,
        ),
        LedgerEntriesCompanion.insert(
          id: 'fuel-ledger',
          userId: 'driver',
          bookingDate: now,
          amount: 75,
          category: 'Tanken',
          sourceType: const Value('vehicle'),
          sourceId: const Value('fuel-cost'),
          vehicleId: const Value('car'),
          accountId: const Value('driver-giro'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await database.watchVehicleCosts('driver').first, hasLength(1));
      expect(await database.watchLedgerEntries('driver').first, hasLength(1));

      await database.deleteVehicle('car', 'driver');

      expect(await database.watchVehicleCosts('driver').first, isEmpty);
      expect(await database.watchLedgerEntries('driver').first, isEmpty);
    },
  );

  test('linked ledger entries update and restore account balances', () async {
    final now = DateTime.now();
    await database.createUser(
      UsersCompanion.insert(
        id: 'linked-owner',
        email: 'linked@example.test',
        displayName: 'Linked',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'giro',
        userId: 'linked-owner',
        bankName: 'Bank',
        label: 'Giro',
        balance: const Value(1000),
        availableBalance: const Value(1000),
        createdAt: now,
        updatedAt: now,
      ),
    );

    LedgerEntriesCompanion booking({
      required bool income,
      required double amount,
    }) => LedgerEntriesCompanion.insert(
      id: 'booking',
      userId: 'linked-owner',
      bookingDate: now,
      amount: amount,
      isIncome: Value(income),
      category: income ? 'Gehalt' : 'Einkaufen',
      accountId: const Value('giro'),
      createdAt: now,
      updatedAt: DateTime.now(),
    );

    await database.saveLedgerEntries([booking(income: false, amount: 50)]);
    expect(
      (await database.watchAccounts('linked-owner').first).single.balance,
      950,
    );

    await database.saveLedgerEntries([booking(income: true, amount: 100)]);
    expect(
      (await database.watchAccounts('linked-owner').first).single.balance,
      1100,
    );

    await database.deleteLedgerEntry('booking', 'linked-owner');
    final restored =
        (await database.watchAccounts('linked-owner').first).single;
    expect(restored.balance, 1000);
    expect(restored.availableBalance, 1000);
  });

  test('future linked entries do not change the balance early', () async {
    final now = DateTime.now();
    await database.createUser(
      UsersCompanion.insert(
        id: 'future-owner',
        email: 'future@example.test',
        displayName: 'Future',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'future-giro',
        userId: 'future-owner',
        bankName: 'Bank',
        label: 'Giro',
        balance: const Value(500),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveLedgerEntry(
      LedgerEntriesCompanion.insert(
        id: 'future-salary',
        userId: 'future-owner',
        bookingDate: now.add(const Duration(days: 2)),
        amount: 3000,
        isIncome: const Value(true),
        category: 'Gehalt',
        accountId: const Value('future-giro'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(
      (await database.watchAccounts('future-owner').first).single.balance,
      500,
    );
  });

  test('advance salary changes balance only in its budget month', () async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    final previousMonthEnd = DateTime(now.year, now.month, 0);
    await database.createUser(
      UsersCompanion.insert(
        id: 'budget-owner',
        email: 'budget@example.test',
        displayName: 'Budget',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'budget-giro',
        userId: 'budget-owner',
        bankName: 'Bank',
        label: 'Giro',
        balance: const Value(500),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveLedgerEntry(
      LedgerEntriesCompanion.insert(
        id: 'current-salary',
        userId: 'budget-owner',
        bookingDate: previousMonthEnd,
        budgetMonth: Value(currentMonth),
        amount: 1000,
        isIncome: const Value(true),
        category: 'Gehalt',
        accountId: const Value('budget-giro'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveLedgerEntry(
      LedgerEntriesCompanion.insert(
        id: 'next-salary',
        userId: 'budget-owner',
        bookingDate: previousMonthEnd,
        budgetMonth: Value(nextMonth),
        amount: 2000,
        isIncome: const Value(true),
        category: 'Gehalt',
        accountId: const Value('budget-giro'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(
      (await database.watchAccounts('budget-owner').first).single.balance,
      1500,
    );
  });

  test('an account cannot be shared by household and portfolio', () async {
    final now = DateTime.now();
    await database.createUser(
      UsersCompanion.insert(
        id: 'usage-owner',
        email: 'usage@example.test',
        displayName: 'Usage',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'usage-account',
        userId: 'usage-owner',
        bankName: 'Bank',
        label: 'Konto',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await database.selectAccountForUsage(
      userId: 'usage-owner',
      accountId: 'usage-account',
      usageType: 'household',
    );

    await expectLater(
      database.selectAccountForUsage(
        userId: 'usage-owner',
        accountId: 'usage-account',
        usageType: 'portfolio',
      ),
      throwsStateError,
    );
  });

  test(
    'an account with household entries is not eligible for portfolio',
    () async {
      final now = DateTime.now();
      await database.createUser(
        UsersCompanion.insert(
          id: 'entry-owner',
          email: 'entry@example.test',
          displayName: 'Entry',
          passwordHash: 'hash',
          passwordSalt: 'salt',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveAccount(
        AccountsCompanion.insert(
          id: 'entry-account',
          userId: 'entry-owner',
          bankName: 'Bank',
          label: 'Konto',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveLedgerEntry(
        LedgerEntriesCompanion.insert(
          id: 'entry',
          userId: 'entry-owner',
          bookingDate: now,
          amount: 10,
          category: 'Test',
          accountId: const Value('entry-account'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(
        await database.accountCanBeUsed(
          'entry-owner',
          'entry-account',
          'portfolio',
        ),
        isFalse,
      );
    },
  );

  test('investment sale reduces stock and credits net proceeds', () async {
    final now = DateTime(2026, 8, 20);
    await database.createUser(
      UsersCompanion.insert(
        id: 'investor',
        email: 'investor@example.test',
        displayName: 'Investor',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.savePreferences(
      UserPreferencesCompanion.insert(userId: 'investor', updatedAt: now),
    );
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'depot-cash',
        userId: 'investor',
        bankName: 'Broker',
        label: 'Depot',
        balance: const Value(100),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveInvestment(
      InvestmentsCompanion.insert(
        id: 'share',
        userId: 'investor',
        accountId: const Value('depot-cash'),
        name: 'Test AG',
        assetType: 'Aktie',
        purchaseDate: now,
        purchasePrice: 100,
        quantity: 10,
        fees: const Value(10),
        currentPrice: 120,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveInvestmentPurchase(
      InvestmentPurchasesCompanion.insert(
        id: 'lot',
        userId: 'investor',
        investmentId: 'share',
        purchaseDate: now,
        purchasePrice: 100,
        quantity: 10,
        fees: const Value(10),
        createdAt: now,
      ),
    );

    await database.sellInvestment(
      userId: 'investor',
      investmentId: 'share',
      quantity: 5,
      pricePerUnit: 120,
      fees: 5,
      soldAt: DateTime(2026, 8, 21),
    );

    final holding = (await database.watchInvestments('investor').first).single;
    final account = (await database.watchAccounts('investor').first).single;
    final sale = (await database.watchPortfolioSales('investor').first).single;
    expect(holding.quantity, 5);
    expect(account.balance, 695);
    expect(sale.proceeds, 595);
    expect(sale.realizedGain, 90);
    expect(sale.allowanceUsed, 90);
    expect(sale.taxPaid, 0);
  });

  test(
    'dated balances are stored and portfolio purchases reduce cash',
    () async {
      final now = DateTime(2026, 8, 20);
      await database.createUser(
        UsersCompanion.insert(
          id: 'history-owner',
          email: 'history@example.test',
          displayName: 'History',
          passwordHash: 'hash',
          passwordSalt: 'salt',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveAccount(
        AccountsCompanion.insert(
          id: 'history-account',
          userId: 'history-owner',
          bankName: 'Broker',
          label: 'Cash',
          balance: const Value(1000),
          availableBalance: const Value(1000),
          createdAt: now,
          updatedAt: now,
        ),
        balanceEffectiveAt: DateTime(2026, 1, 1),
      );

      await database.applyPortfolioPurchaseToCash(
        userId: 'history-owner',
        accountId: 'history-account',
        amount: 275,
        purchasedAt: now,
      );

      final histories = await database
          .watchAccountBalanceHistories('history-owner')
          .first;
      final account =
          (await database.watchAccounts('history-owner').first).single;
      expect(histories, hasLength(1));
      expect(histories.single.balance, 1000);
      expect(account.balance, 725);
      expect(account.availableBalance, 725);
    },
  );
}

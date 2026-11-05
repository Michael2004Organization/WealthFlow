import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';

/// Rechenfehler aus der Prüfung vom 05.11.2026 (Punkte 1–4, 6–8).
void main() {
  late AppDatabase database;
  final now = DateTime(2026, 3, 10);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<void> user(String id, {String role = 'admin'}) async {
    await database.createUser(
      UsersCompanion.insert(
        id: id,
        email: '$id@example.test',
        displayName: id,
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: Value(role),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.savePreferences(
      UserPreferencesCompanion.insert(userId: id, updatedAt: now),
    );
  }

  Future<void> account(String id, String userId, {double balance = 1000}) =>
      database.saveAccount(
        AccountsCompanion.insert(
          id: id,
          userId: userId,
          bankName: 'Broker',
          label: id,
          balance: Value(balance),
          availableBalance: Value(balance),
          createdAt: now,
          updatedAt: now,
        ),
      );

  Future<void> position(
    String id,
    String userId,
    String accountId, {
    String currency = 'EUR',
    double price = 100,
    double currentPrice = 100,
    String country = '',
  }) => database.saveInvestment(
    InvestmentsCompanion.insert(
      id: id,
      userId: userId,
      accountId: Value(accountId),
      name: 'Test $id',
      assetType: 'Aktie',
      instrumentCurrency: Value(currency),
      country: Value(country),
      purchaseDate: now,
      purchasePrice: price,
      quantity: 0,
      currentPrice: currentPrice,
      createdAt: now,
      updatedAt: now,
    ),
  );

  Future<Account> cash(String userId, String id) async =>
      (await database.watchAccounts(userId).first).singleWhere(
        (row) => row.id == id,
      );

  test('1: einen Kauf löschen oder ändern bucht das Geld zurück', () async {
    await user('u');
    await account('depot', 'u');
    await position('share', 'u', 'depot');
    await database.recordInvestmentPurchase(
      id: 'lot',
      userId: 'u',
      investmentId: 'share',
      purchaseDate: now,
      purchasePrice: 100,
      quantity: 2,
      fees: 5,
      buy: true,
    );
    expect((await cash('u', 'depot')).balance, 795);

    await database.updateInvestmentPurchase(
      userId: 'u',
      purchaseId: 'lot',
      purchaseDate: now,
      purchasePrice: 100,
      quantity: 3,
      fees: 5,
    );
    var depot = await cash('u', 'depot');
    expect(depot.balance, 695);
    expect(depot.availableBalance, 695);

    await database.recordInvestmentPurchase(
      id: 'second',
      userId: 'u',
      investmentId: 'share',
      purchaseDate: now,
      purchasePrice: 50,
      quantity: 1,
      fees: 0,
      buy: true,
    );
    await database.deleteInvestmentPurchase('second', 'u');
    depot = await cash('u', 'depot');
    expect(depot.balance, 695);
    expect(depot.availableBalance, 695);
  });

  test('2: Fremdwährung wird beim Kauf und im Vermögen umgerechnet', () async {
    await user('u');
    await database.saveCountryExchangeRate(
      actorUserId: 'u',
      country: 'USA',
      currency: 'USD',
      exchangeRate: .9,
    );
    await account('depot', 'u');
    await position('apple', 'u', 'depot', currency: 'USD', currentPrice: 120);
    await database.recordInvestmentPurchase(
      userId: 'u',
      investmentId: 'apple',
      purchaseDate: now,
      purchasePrice: 100,
      quantity: 2,
      fees: 0,
      buy: true,
    );
    // 200 USD × 0,90 = 180 EUR vom Euro-Konto
    expect((await cash('u', 'depot')).balance, closeTo(820, 1e-9));

    await database.captureNetWorth('u');
    final snapshot = (await database.watchNetWorthSnapshots('u').first).last;
    // 2 × 120 USD × 0,90 = 216 EUR
    expect(snapshot.portfolioValue, closeTo(216, 1e-9));

    await database.sellInvestment(
      userId: 'u',
      investmentId: 'apple',
      quantity: 1,
      pricePerUnit: 120,
      fees: 0,
      soldAt: now,
    );
    final sale = (await database.watchPortfolioSales('u').first).single;
    expect(sale.sourceCurrency, 'USD');
    expect(sale.exchangeRate, closeTo(.9, 1e-9));
    // Erlös 108 EUR, Einstand 90 EUR: 18 EUR Gewinn, unter dem Freibetrag
    expect(sale.costBasis, closeTo(90, 1e-9));
    expect(sale.proceeds, closeTo(108, 1e-9));
    expect((await cash('u', 'depot')).balance, closeTo(928, 1e-9));
  });

  test('3: Bruchstücke aus Sparplänen bleiben erhalten', () async {
    await user('u');
    await account('depot', 'u');
    await position('etf', 'u', 'depot');
    for (final quantity in [0.1234, 0.5678]) {
      await database.recordInvestmentPurchase(
        userId: 'u',
        investmentId: 'etf',
        purchaseDate: now,
        purchasePrice: 100,
        quantity: quantity,
        fees: 0,
        buy: false,
      );
    }
    final etf = (await database.watchInvestments('u').first).single;
    expect(etf.quantity, closeTo(0.6912, 1e-12));
  });

  test('4: Verkauf rechnet nach FIFO mit den ältesten Käufen', () async {
    await user('u');
    await account('depot', 'u', balance: 0);
    await position('share', 'u', 'depot');
    await database.recordInvestmentPurchase(
      userId: 'u',
      investmentId: 'share',
      purchaseDate: DateTime(2025, 1, 1),
      purchasePrice: 100,
      quantity: 10,
      fees: 0,
      buy: false,
    );
    await database.recordInvestmentPurchase(
      userId: 'u',
      investmentId: 'share',
      purchaseDate: DateTime(2025, 6, 1),
      purchasePrice: 200,
      quantity: 10,
      fees: 0,
      buy: false,
    );
    await database.sellInvestment(
      userId: 'u',
      investmentId: 'share',
      quantity: 15,
      pricePerUnit: 250,
      fees: 0,
      soldAt: now,
    );
    final sale = (await database.watchPortfolioSales('u').first).single;
    // 10 × 100 + 5 × 200 statt 15 × 150 (Durchschnitt)
    expect(sale.costBasis, closeTo(2000, 1e-9));
    final left = (await database.watchInvestments('u').first).single;
    expect(left.quantity, closeTo(5, 1e-9));
    expect(left.purchasePrice, closeTo(200, 1e-9));
  });

  test(
    '6: Wechselkurs ändert keine bezahlten Dividenden, nur Admins bei mehreren Benutzern',
    () async {
      await user('admin');
      await user('member', role: 'member');
      await account('depot', 'admin');
      await position('ko', 'admin', 'depot', currency: 'USD', country: 'USA');
      final paid = DateTime.now().subtract(const Duration(days: 60));
      final open = DateTime.now().add(const Duration(days: 60));
      for (final (id, date) in [('paid', paid), ('open', open)]) {
        await database.saveDividendSchedule(
          DividendSchedulesCompanion.insert(
            id: id,
            userId: 'admin',
            investmentId: 'ko',
            paymentMonth: date.month,
            amountPerShare: 1,
            paymentDate: Value(date),
            paymentYear: Value(date.year),
            currency: const Value('USD'),
            exchangeRate: const Value(.8),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      await expectLater(
        database.saveCountryExchangeRate(
          actorUserId: 'member',
          country: 'USA',
          currency: 'USD',
          exchangeRate: .95,
        ),
        throwsStateError,
      );

      await database.saveCountryExchangeRate(
        actorUserId: 'admin',
        country: 'USA',
        currency: 'USD',
        exchangeRate: .95,
      );
      final schedules = {
        for (final row in await database.watchDividendSchedules('admin').first)
          row.id: row.exchangeRate,
      };
      expect(schedules['paid'], .8);
      expect(schedules['open'], .95);
    },
  );

  test('7: Gold verkaufen bucht auch den verfügbaren Betrag', () async {
    await user('u');
    await account('giro', 'u', balance: 100);
    await account('depot', 'u');
    await database.savePhysicalAsset(
      PhysicalAssetsCompanion.insert(
        id: 'gold',
        userId: 'u',
        accountId: const Value('depot'),
        name: 'Goldbarren',
        weightGrams: const Value(10),
        purchasePrice: const Value(500),
        currentPricePerGram: const Value(60),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.sellPhysicalAsset(
      userId: 'u',
      assetId: 'gold',
      grams: 10,
      pricePerGram: 60,
      fees: 0,
      soldAt: now,
      destinationAccountId: 'giro',
    );
    final giro = await cash('u', 'giro');
    expect(giro.balance, 700);
    expect(giro.availableBalance, 700);
  });

  test('8: gelöschte Konten wirken nicht weiter', () async {
    await user('u');
    await account('depot', 'u');
    await position('share', 'u', 'depot');
    await database.recordInvestmentPurchase(
      userId: 'u',
      investmentId: 'share',
      purchaseDate: now,
      purchasePrice: 100,
      quantity: 1,
      fees: 0,
      buy: false,
    );
    await expectLater(database.deleteAccount('depot', 'u'), throwsStateError);
    expect(await database.watchInvestments('u').first, hasLength(1));

    // Ältere Daten: Konto gelöscht, Position noch da.
    await (database.update(database.accounts)
          ..where((row) => row.id.equals('depot')))
        .write(AccountsCompanion(deletedAt: Value(DateTime.now().toUtc())));
    expect(await database.watchInvestments('u').first, isEmpty);
    await database.captureNetWorth('u');
    final snapshot = (await database.watchNetWorthSnapshots('u').first).last;
    expect(snapshot.portfolioValue, 0);
    await expectLater(
      database.sellInvestment(
        userId: 'u',
        investmentId: 'share',
        quantity: 1,
        pricePerUnit: 100,
        fees: 0,
        soldAt: now,
      ),
      throwsStateError,
    );
  });
}

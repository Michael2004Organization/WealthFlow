import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/market_data/market_data_service.dart';
import 'package:wealthflow_core/database/app_database.dart';

void main() {
  late AppDatabase database;
  late MarketDataCoordinator coordinator;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    coordinator = MarketDataCoordinator(database);
  });

  tearDown(() => database.close());

  test('uses only the three configured daily refresh slots', () {
    expect(coordinator.latestDueSlot(DateTime(2026, 8, 6, 9)), isNull);
    expect(
      coordinator.latestDueSlot(DateTime(2026, 8, 6, 16)),
      DateTime(2026, 8, 6, 15),
    );
    expect(
      coordinator.latestDueSlot(DateTime(2026, 8, 6, 23)),
      DateTime(2026, 8, 6, 19),
    );
  });

  test('builds one deduplicated batch for the shared stock pool', () async {
    final now = DateTime.utc(2026, 8, 6, 15, 30);
    await database.createUser(
      UsersCompanion.insert(
        id: 'admin',
        email: 'admin@example.test',
        displayName: 'Admin',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: const Value('admin'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveStockMaster(
      'admin',
      StockMastersCompanion.insert(
        id: 'apple',
        name: 'Apple',
        symbol: 'AAPL',
        country: const Value('USA'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveStockMaster(
      'admin',
      StockMastersCompanion.insert(
        id: 'microsoft',
        name: 'Microsoft',
        symbol: 'MSFT',
        country: const Value('USA'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final first = await coordinator.quotePlan(now, apiKey: 'test-key');
    expect(first.symbols, ['AAPL', 'MSFT']);

    await database.markMarketRefresh('quotes', 'global', first.slot);
    final cached = await coordinator.quotePlan(now, apiKey: 'test-key');
    expect(cached.isEmpty, isTrue);
  });

  test('tracks the 250 request daily ceiling', () async {
    final now = DateTime(2026, 8, 6, 12);
    expect(await coordinator.remainingRequests(now), 250);
    await coordinator.recordRequest(now);
    expect(await coordinator.remainingRequests(now), 249);
  });

  test('does not plan requests without an API key', () async {
    final plan = await coordinator.quotePlan(
      DateTime(2026, 8, 6, 15),
      apiKey: null,
    );
    expect(plan.isEmpty, isTrue);
    expect(plan.reason, contains('API-Key'));
  });

  test('plans an immediate exchange-rate batch after API key setup', () async {
    final now = DateTime.utc(2026, 8, 6, 9);
    await database.createUser(
      UsersCompanion.insert(
        id: 'exchange-admin',
        email: 'exchange@example.test',
        displayName: 'Exchange Admin',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: const Value('admin'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveCountryExchangeRate(
      actorUserId: 'exchange-admin',
      country: 'USA',
      currency: 'USD',
      exchangeRate: .92,
    );

    final plan = await coordinator.exchangeRatePlan(
      now,
      apiKey: 'exchange-key',
      baseCurrency: 'EUR',
    );

    expect(plan.currencies, ['USD']);
    expect(plan.reason, contains('Erste Abfrage'));
  });

  test('members cannot mutate the shared stock catalogue', () async {
    final now = DateTime.utc(2026, 8, 6);
    await database.createUser(
      UsersCompanion.insert(
        id: 'member',
        email: 'member@example.test',
        displayName: 'Member',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await expectLater(
      database.saveStockMaster(
        'member',
        StockMastersCompanion.insert(
          id: 'blocked',
          name: 'Blocked',
          symbol: 'BLOCK',
          country: const Value('USA'),
          createdAt: now,
          updatedAt: now,
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });
}

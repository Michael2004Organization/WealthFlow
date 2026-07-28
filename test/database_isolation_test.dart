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
}

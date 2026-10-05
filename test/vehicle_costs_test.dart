import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';

const _userId = 'driver';
final _now = DateTime.utc(2026, 10, 1);

Future<AppDatabase> _database() async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  await database.createUser(
    UsersCompanion.insert(
      id: _userId,
      email: 'driver@example.test',
      displayName: 'Driver',
      passwordHash: 'hash',
      passwordSalt: 'salt',
      createdAt: _now,
      updatedAt: _now,
    ),
  );
  await database.savePreferences(
    UserPreferencesCompanion.insert(userId: _userId, updatedAt: _now),
  );
  await database.saveAccount(
    AccountsCompanion.insert(
      id: 'giro',
      userId: _userId,
      bankName: 'Bank',
      label: 'Haushalt',
      balance: const Value(500),
      availableBalance: const Value(500),
      usageType: const Value('household'),
      createdAt: _now,
      updatedAt: _now,
    ),
  );
  await database.saveVehicle(
    VehiclesCompanion.insert(
      id: 'car',
      userId: _userId,
      vehicleType: 'Auto',
      make: 'Test',
      model: 'Car',
      year: 2024,
      createdAt: _now,
      updatedAt: _now,
    ),
  );
  return database;
}

Future<void> _saveFuel(
  AppDatabase database, {
  required String ledgerId,
  required double amount,
}) => database.saveVehicleCostWithLedger(
  VehicleCostsCompanion.insert(
    id: 'fuel-cost',
    userId: _userId,
    vehicleId: 'car',
    bookingDate: _now,
    category: 'Tanken',
    amount: amount,
    createdAt: _now,
    updatedAt: _now,
  ),
  LedgerEntriesCompanion.insert(
    id: ledgerId,
    userId: _userId,
    bookingDate: _now,
    amount: amount,
    category: 'Tanken',
    sourceType: const Value('vehicle'),
    sourceId: const Value('fuel-cost'),
    vehicleId: const Value('car'),
    accountId: const Value('giro'),
    createdAt: _now,
    updatedAt: _now,
  ),
);

void main() {
  late AppDatabase database;

  setUp(() async => database = await _database());
  tearDown(() => database.close());

  Future<double> balance() async =>
      (await database.watchAccounts(_userId).first).single.balance;

  test('editing a vehicle cost updates its booking in place', () async {
    await _saveFuel(database, ledgerId: 'first-ledger', amount: 75);
    expect(await balance(), 425);

    // The editor sends a fresh ledger id; the existing booking is reused.
    await _saveFuel(database, ledgerId: 'second-ledger', amount: 100);

    final entries = await database.watchLedgerEntries(_userId).first;
    expect(entries, hasLength(1));
    expect(entries.single.id, 'first-ledger');
    expect(entries.single.amount, 100);
    expect(
      (await database.watchVehicleCosts(_userId).first).single.amount,
      100,
    );
    expect(await balance(), 400);
  });

  test('deleting the booking also removes the vehicle cost', () async {
    await _saveFuel(database, ledgerId: 'fuel-ledger', amount: 75);

    await database.deleteLedgerEntry('fuel-ledger', _userId);

    expect(await database.watchVehicleCosts(_userId).first, isEmpty);
    expect(await database.watchLedgerEntries(_userId).first, isEmpty);
    expect(await balance(), 500);
  });

  test('deleting a vehicle cost removes its booking and refunds', () async {
    await _saveFuel(database, ledgerId: 'fuel-ledger', amount: 75);

    await database.deleteVehicleCost('fuel-cost', _userId);

    expect(await database.watchVehicleCosts(_userId).first, isEmpty);
    expect(await database.watchLedgerEntries(_userId).first, isEmpty);
    expect(await balance(), 500);
  });

  test('a cost booked in the household book can be deleted too', () async {
    await database.saveLedgerEntries([
      LedgerEntriesCompanion.insert(
        id: 'household-fuel',
        userId: _userId,
        bookingDate: _now,
        amount: 60,
        category: 'Tanken',
        vehicleId: const Value('car'),
        accountId: const Value('giro'),
        createdAt: _now,
        updatedAt: _now,
      ),
    ]);
    final cost = (await database.watchVehicleCosts(_userId).first).single;
    expect(cost.id, 'ledger:household-fuel');
    expect(await balance(), 440);

    await database.deleteVehicleCost(cost.id, _userId);

    expect(await database.watchVehicleCosts(_userId).first, isEmpty);
    expect(await database.watchLedgerEntries(_userId).first, isEmpty);
    expect(await balance(), 500);
  });
}

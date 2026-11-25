import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';

const _userId = 'owner';

void main() {
  late AppDatabase database;
  final day = DateTime(2026, 10, 1);

  Future<double> balance(String id) async =>
      (await database.watchAccounts(_userId).first)
          .firstWhere((account) => account.id == id)
          .balance;

  LedgerEntriesCompanion booking(
    String id, {
    String account = 'giro',
    bool income = false,
    String sourceType = '',
    String sourceId = '',
  }) => LedgerEntriesCompanion.insert(
    id: id,
    userId: _userId,
    bookingDate: day,
    amount: 25,
    isIncome: Value(income),
    category: 'Sonstiges',
    accountId: Value(account),
    sourceType: Value(sourceType),
    sourceId: Value(sourceId),
    createdAt: day,
    updatedAt: day,
  );

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.utc(2026, 10, 1);
    await database.createUser(
      UsersCompanion.insert(
        id: _userId,
        email: 'owner@example.test',
        displayName: 'Owner',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.savePreferences(
      UserPreferencesCompanion.insert(userId: _userId, updatedAt: now),
    );
    for (final id in ['giro', 'tagesgeld']) {
      await database.saveAccount(
        AccountsCompanion.insert(
          id: id,
          userId: _userId,
          bankName: 'Bank',
          label: id,
          balance: const Value(1000),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  });

  tearDown(() => database.close());

  test('a deleted booking is in the Papierkorb and comes back', () async {
    await database.saveLedgerEntries([booking('rent')]);
    expect(await balance('giro'), 975);

    await database.deleteLedgerEntry('rent', _userId);
    expect(await balance('giro'), 1000);
    final trash = await database.watchDeletedLedgerEntries(_userId).first;
    expect(trash.map((entry) => entry.id), ['rent']);

    expect(await database.restoreFromTrash(trash.single), 1);
    expect(await balance('giro'), 975);
    expect(await database.watchDeletedLedgerEntries(_userId).first, isEmpty);
  });

  test('a transfer comes back with both legs', () async {
    await database.saveLedgerEntries([
      booking('out', sourceType: 'transfer', sourceId: 't1'),
      booking(
        'in',
        account: 'tagesgeld',
        income: true,
        sourceType: 'transfer',
        sourceId: 't1',
      ),
    ]);
    await database.deleteLinkedLedgerEntries('t1', _userId);
    expect(await balance('giro'), 1000);
    expect(await balance('tagesgeld'), 1000);

    final trash = await database.watchDeletedLedgerEntries(_userId).first;
    expect(await database.restoreFromTrash(trash.first), 2);
    expect(await balance('giro'), 975);
    expect(await balance('tagesgeld'), 1025);
  });

  test('dividend bookings are not listed', () async {
    await database.saveLedgerEntries([
      booking('div', income: true, sourceType: 'dividend', sourceId: 'x'),
    ]);
    await database.deleteLedgerEntry('div', _userId);
    expect(await database.watchDeletedLedgerEntries(_userId).first, isEmpty);
  });
}

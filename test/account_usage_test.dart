import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/database/app_database.dart';

const _userId = 'owner';

void main() {
  late AppDatabase database;

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
    await database.saveAccount(
      AccountsCompanion.insert(
        id: 'giro',
        userId: _userId,
        bankName: 'Bank',
        label: 'Giro',
        balance: const Value(1000),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveLedgerEntries([
      for (final id in ['rent', 'food'])
        LedgerEntriesCompanion.insert(
          id: id,
          userId: _userId,
          bookingDate: now,
          amount: 10,
          category: 'Sonstiges',
          accountId: const Value('giro'),
          createdAt: now,
          updatedAt: now,
        ),
    ]);
  });

  tearDown(() => database.close());

  test('an account with several bookings can still be selected', () async {
    await database.selectAccountForUsage(
      userId: _userId,
      accountId: 'giro',
      usageType: 'household',
    );

    final account = (await database.watchAccounts(_userId).first).single;
    expect(account.usageType, 'household');
  });

  test('several bookings block the portfolio with a clear reason', () async {
    expect(
      await database.accountCanBeUsed(_userId, 'giro', 'portfolio'),
      isFalse,
    );
    await expectLater(
      database.selectAccountForUsage(
        userId: _userId,
        accountId: 'giro',
        usageType: 'portfolio',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('anderen Modul'),
        ),
      ),
    );
  });
}

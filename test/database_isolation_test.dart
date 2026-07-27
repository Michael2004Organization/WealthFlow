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
}

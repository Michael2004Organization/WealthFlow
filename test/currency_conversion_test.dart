import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/currency_conversion.dart';

void main() {
  test('converts foreign amounts into the standard currency', () {
    final converter = CurrencyConverter('eur', {'USD': 0.9, 'CHF': 1.05});

    expect(converter.toBase(100, 'EUR'), 100);
    expect(converter.toBase(100, 'usd'), closeTo(90, 0.0001));
    expect(converter.toBase(100, 'CHF'), closeTo(105, 0.0001));
    expect(converter.canConvert('GBP'), isFalse);
    expect(converter.toBase(100, 'GBP'), 100);
  });

  test('net worth snapshot converts foreign accounts', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.utc(2026, 9, 1);
    await database.createUser(
      UsersCompanion.insert(
        id: 'user',
        email: 'user@example.test',
        displayName: 'User',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.savePreferences(
      UserPreferencesCompanion.insert(userId: 'user', updatedAt: now),
    );
    await database
        .into(database.countryTaxRates)
        .insert(
          CountryTaxRatesCompanion.insert(
            country: 'USA',
            currency: const Value('USD'),
            exchangeRate: const Value(0.9),
            updatedAt: now,
          ),
        );
    for (final (id, currency) in [('giro', 'EUR'), ('us', 'USD')]) {
      await database.saveAccount(
        AccountsCompanion.insert(
          id: id,
          userId: 'user',
          bankName: 'Bank',
          label: id,
          currency: Value(currency),
          balance: const Value(1000),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    await database.captureNetWorth('user');
    final snapshot = (await database.watchNetWorthSnapshots('user').first).last;

    expect(snapshot.accountBalance, closeTo(1900, 0.0001));
  });
}

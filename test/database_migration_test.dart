import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/database/app_database.dart';

void main() {
  test('schema 17 migrates portfolio masters and country currencies', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute('PRAGMA foreign_keys = ON');
        database.execute('''
          CREATE TABLE stock_masters (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            symbol TEXT NOT NULL UNIQUE,
            isin TEXT NOT NULL DEFAULT '',
            wkn TEXT NOT NULL DEFAULT '',
            currency TEXT NOT NULL DEFAULT 'EUR',
            dividend_currency TEXT NOT NULL DEFAULT 'EUR',
            country TEXT NOT NULL DEFAULT '',
            exchange TEXT NOT NULL DEFAULT '',
            broker TEXT NOT NULL DEFAULT '',
            sector TEXT NOT NULL DEFAULT '',
            dividend_frequency TEXT NOT NULL DEFAULT 'jährlich',
            dividend_start_month INTEGER NOT NULL DEFAULT 1,
            company_data TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER
          )
        ''');
        database.execute('''
          CREATE TABLE investments (
            id TEXT NOT NULL PRIMARY KEY,
            stock_id TEXT,
            asset_type TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE country_tax_rates (
            country TEXT NOT NULL PRIMARY KEY,
            withholding_tax_rate REAL NOT NULL DEFAULT 0,
            currency TEXT NOT NULL DEFAULT 'EUR',
            exchange_rate REAL NOT NULL DEFAULT 1,
            allow_manual_exchange_rate INTEGER NOT NULL DEFAULT 1,
            exchange_rate_updated_at INTEGER,
            updated_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE stock_prices (
            stock_id TEXT NOT NULL PRIMARY KEY
              REFERENCES stock_masters(id),
            price REAL NOT NULL,
            currency TEXT NOT NULL DEFAULT 'EUR',
            quoted_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE stock_dividends (
            id TEXT NOT NULL PRIMARY KEY,
            stock_id TEXT NOT NULL REFERENCES stock_masters(id),
            ex_date INTEGER NOT NULL,
            payment_date INTEGER,
            amount REAL NOT NULL,
            currency TEXT NOT NULL DEFAULT 'EUR',
            fetched_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE master_data (
            id TEXT NOT NULL PRIMARY KEY,
            user_id TEXT NOT NULL,
            kind TEXT NOT NULL,
            value TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER,
            deleted_at INTEGER,
            UNIQUE(user_id, kind, value)
          )
        ''');
        database.execute('''
          CREATE TABLE asset_classes (
            name TEXT NOT NULL PRIMARY KEY,
            display_order INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          INSERT INTO stock_masters
            (id, name, symbol, country, created_at, updated_at)
          VALUES ('world-etf', 'World ETF', 'WORLD', 'Schweiz', 0, 0)
        ''');
        database.execute('''
          INSERT INTO investments (id, stock_id, asset_type, created_at)
          VALUES ('position', 'world-etf', 'ETF', 0)
        ''');
        database.execute('''
          INSERT INTO stock_prices (stock_id, price, currency, quoted_at)
          VALUES ('world-etf', 123.45, 'CHF', 0)
        ''');
        database.execute('''
          INSERT INTO stock_dividends
            (id, stock_id, ex_date, amount, currency, fetched_at)
          VALUES ('dividend', 'world-etf', 0, 1.25, 'CHF', 0)
        ''');
        database.execute('''
          INSERT INTO country_tax_rates
            (country, withholding_tax_rate, currency, updated_at)
          VALUES ('USA', 15, 'EUR', 0)
        ''');
        database.userVersion = 17;
      },
    );
    final database = AppDatabase.forTesting(executor);
    addTearDown(database.close);

    final master = (await database.stockPool()).single;
    final rates = await database.watchCountryTaxRates().first;

    expect(master.assetType, 'ETF');
    expect(master.dividendPerShare, 0);
    expect((await database.stockPrice('world-etf'))?.price, 123.45);
    expect(
      await database.stockDividendsForYear('world-etf', 1970),
      hasLength(1),
    );
    expect(rates.firstWhere((rate) => rate.country == 'USA').currency, 'USD');
    expect(
      rates.firstWhere((rate) => rate.country == 'Schweiz').currency,
      'CHF',
    );
    expect(await database.watchAssetClasses().first, hasLength(7));
    final snapshotColumns = await database
        .customSelect("PRAGMA table_info('net_worth_snapshots')")
        .get();
    expect(
      snapshotColumns.map((row) => row.data['name']),
      contains('vehicle_value'),
    );
  });
}

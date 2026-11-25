import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/trade_republic_csv.dart';

const _userId = 'owner';

// Layout as described for the Trade Republic export (comma variant).
const _header =
    '"datetime","date","account_type","category","type","asset_class",'
    '"name","symbol","shares","price","amount","fee","tax","currency",'
    '"original_amount","original_currency","fx_rate","description",'
    '"transaction_id","counterparty_name","counterparty_iban",'
    '"payment_reference","mcc_code"';

String _row(
  String date,
  String type,
  String assetClass,
  String name,
  String isin,
  String shares,
  String price,
  String amount,
  String fee,
  String tax,
  String id, {
  String account = 'DEFAULT',
}) =>
    '"${date}T09:00:00.000Z","$date","$account","TRADING","$type",'
    '"$assetClass","$name","$isin","$shares","$price","$amount","$fee",'
    '"$tax","EUR","","","","","$id","","","",""';

final _csv = [
  _header,
  _row(
    '2026-01-02',
    'CUSTOMER_INBOUND',
    '',
    '',
    '',
    '',
    '',
    '1000.00',
    '',
    '',
    'in-1',
  ),
  _row(
    '2026-01-05',
    'BUY',
    'STOCK',
    'Apple',
    'US0378331005',
    '2.0000000000',
    '180.500000',
    '-361.00',
    '-1.00',
    '',
    'buy-1',
  ),
  _row(
    '2026-02-01',
    'SAVINGS_PLAN_EXECUTED',
    'FUND',
    'Core MSCI World USD (Acc)',
    'IE00B4L5Y983',
    '1.2345000000',
    '101.230000',
    '-124.97',
    '',
    '',
    'plan-1',
  ),
  _row(
    '2026-03-10',
    'DIVIDEND',
    'STOCK',
    'Apple',
    'US0378331005',
    '2.0000000000',
    '',
    '0.52',
    '',
    '-0.08',
    'div-1',
  ),
  _row(
    '2026-07-15',
    'SELL',
    'STOCK',
    'Apple',
    'US0378331005',
    '-1.0000000000',
    '210.000000',
    '210.00',
    '-1.00',
    '-7.65',
    'sell-1',
  ),
  _row(
    '2026-08-01',
    'BUY',
    'STOCK',
    'Kinderaktie',
    'DE0001',
    '1',
    '10',
    '-10.00',
    '',
    '',
    'junior-1',
    account: 'JUNIOR',
  ),
].join('\n');

void main() {
  group('parser', () {
    test('reads buys, savings plans, dividends and sells', () {
      final result = parseTradeRepublicCsv(_csv);
      expect(result.error, isNull);
      expect(result.transactions.map((row) => row.kind), [
        BrokerTransactionKind.buy,
        BrokerTransactionKind.buy,
        BrokerTransactionKind.dividend,
        BrokerTransactionKind.sell,
      ]);
      final buy = result.transactions.first;
      expect(buy.isin, 'US0378331005');
      expect(buy.shares, 2);
      expect(buy.price, 180.5);
      expect(buy.fee, 1);
      expect(result.transactions[1].assetType, 'ETF');
      final dividend = result.transactions[2];
      expect(dividend.netAmount, closeTo(.44, 1e-9));
      final sell = result.transactions[3];
      expect(sell.shares, 1);
      expect(sell.tax, 7.65);
      expect(result.skippedTypes, {'CUSTOMER_INBOUND': 1, 'Junior-Depot': 1});
    });

    test('semicolon variant and German numbers', () {
      final result = parseTradeRepublicCsv(
        'date;type;name;symbol;shares;price;amount;fee;tax\n'
        '05.01.2026;Kauf;Apple;US0378331005;2;180,50;-361,00;-1,00;0\n',
      );
      expect(result.transactions.single.price, 180.5);
      expect(result.transactions.single.date, DateTime(2026, 1, 5));
    });

    test('rejects other files', () {
      expect(
        parseTradeRepublicCsv('Buchungstag;Betrag\n1.1.2026;5').error,
        isNotNull,
      );
    });
  });

  group('import', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      final now = DateTime.utc(2026, 1, 1);
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
          id: 'tr',
          userId: _userId,
          bankName: 'Trade Republic',
          label: 'Depot',
          balance: const Value(1000),
          usageType: const Value('portfolio'),
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    tearDown(() => database.close());

    test('books positions, sale and dividend once', () async {
      final rows = parseTradeRepublicCsv(_csv).transactions;
      final first = await database.importBrokerTransactions(
        userId: _userId,
        accountId: 'tr',
        transactions: rows,
      );
      expect(first.failures, isEmpty);
      expect(first.buys, 2);
      expect(first.createdPositions, 2);
      expect(first.sells, 1);
      expect(first.dividends, 1);

      final positions = await database.select(database.investments).get();
      final apple = positions.firstWhere((item) => item.isin == 'US0378331005');
      expect(apple.quantity, 1);
      expect(apple.assetType, 'Aktie');
      expect(
        positions.firstWhere((item) => item.isin == 'IE00B4L5Y983').assetType,
        'ETF',
      );

      final again = await database.importBrokerTransactions(
        userId: _userId,
        accountId: 'tr',
        transactions: rows,
      );
      expect(again.imported, 0);
      expect(again.duplicates, 4);
      final after = await database.select(database.investments).get();
      expect(
        after.firstWhere((item) => item.isin == 'US0378331005').quantity,
        1,
      );
    });

    test('a sale without position is reported, not guessed', () async {
      final sell = parseTradeRepublicCsv(_csv).transactions.last;
      final summary = await database.importBrokerTransactions(
        userId: _userId,
        accountId: 'tr',
        transactions: [sell],
      );
      expect(summary.imported, 0);
      expect(summary.failures.single, contains('US0378331005'));
    });
  });
}

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../storage/data_export.dart';
import '../security/data_cipher.dart';
import '../finance/budget_period.dart';
import '../finance/currencies.dart';
import '../finance/currency_conversion.dart';
import '../finance/dividend_math.dart';
import '../finance/portfolio_master_data.dart';
import '../finance/sale_tax.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  TextColumn get profileImagePath => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get bankName => text()();
  TextColumn get label => text()();
  TextColumn get holder => text().withDefault(const Constant(''))();
  TextColumn get iban => text().withDefault(const Constant(''))();
  TextColumn get bic => text().withDefault(const Constant(''))();
  TextColumn get accountNumber => text().withDefault(const Constant(''))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  RealColumn get balance => real().withDefault(const Constant(0))();
  RealColumn get availableBalance => real().withDefault(const Constant(0))();
  TextColumn get usageType =>
      text().withDefault(const Constant('unassigned'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AccountBalanceHistories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  DateTimeColumn get effectiveAt => dateTime()();
  RealColumn get balance => real()();
  RealColumn get availableBalance => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get stockId => text().nullable()();
  TextColumn get accountId => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get symbol => text().withDefault(const Constant(''))();
  TextColumn get isin => text().withDefault(const Constant(''))();
  TextColumn get wkn => text().withDefault(const Constant(''))();
  TextColumn get assetType => text()();
  // Additional product metadata. Empty values keep existing stock/ETF rows
  // backwards compatible while bonds and derivatives can share the portfolio
  // and purchase ledger.
  TextColumn get instrumentSubtype => text().withDefault(const Constant(''))();
  TextColumn get positionDirection => text().withDefault(const Constant(''))();
  TextColumn get issuer => text().withDefault(const Constant(''))();
  TextColumn get underlying => text().withDefault(const Constant(''))();
  TextColumn get instrumentCurrency =>
      text().withDefault(const Constant('EUR'))();
  RealColumn get nominalValue => real().withDefault(const Constant(0))();
  RealColumn get couponRate => real().withDefault(const Constant(0))();
  DateTimeColumn get maturityDate => dateTime().nullable()();
  RealColumn get strikePrice => real().withDefault(const Constant(0))();
  RealColumn get knockOutBarrier => real().withDefault(const Constant(0))();
  RealColumn get leverage => real().withDefault(const Constant(0))();
  RealColumn get subscriptionRatio => real().withDefault(const Constant(0))();
  TextColumn get broker => text().withDefault(const Constant(''))();
  TextColumn get country => text().withDefault(const Constant(''))();
  TextColumn get sector => text().withDefault(const Constant(''))();
  DateTimeColumn get purchaseDate => dateTime()();
  RealColumn get purchasePrice => real()();
  RealColumn get quantity => real()();
  RealColumn get fees => real().withDefault(const Constant(0))();
  RealColumn get currentPrice => real()();
  // Legacy column name kept for a non-destructive migration. The stored value
  // is the dividend per share and payout; frequency controls projections.
  RealColumn get annualDividend => real().withDefault(const Constant(0))();
  TextColumn get dividendCurrency =>
      text().withDefault(const Constant('EUR'))();
  // Units of the user's standard currency received for one currency unit.
  RealColumn get dividendExchangeRate =>
      real().withDefault(const Constant(1))();
  RealColumn get dividendWithholdingTaxRate =>
      real().withDefault(const Constant(0))();
  TextColumn get dividendFrequency =>
      text().withDefault(const Constant('jährlich'))();
  IntColumn get dividendStartMonth =>
      integer().withDefault(const Constant(1))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class InvestmentPurchases extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get investmentId => text().references(Investments, #id)();
  DateTimeColumn get purchaseDate => dateTime()();
  RealColumn get purchasePrice => real()();
  RealColumn get quantity => real()();
  RealColumn get fees => real().withDefault(const Constant(0))();
  BoolColumn get cashApplied => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DividendSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get investmentId => text().references(Investments, #id)();
  IntColumn get paymentMonth => integer()();
  RealColumn get amountPerShare => real()();
  DateTimeColumn get exDate => dateTime().nullable()();
  DateTimeColumn get paymentDate => dateTime().nullable()();
  IntColumn get paymentYear => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  RealColumn get exchangeRate => real().withDefault(const Constant(1))();
  RealColumn get withholdingTaxRate => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Shared, user-independent portfolio catalogue. Portfolio rows only reference
/// these records; this prevents duplicate market-data requests per user.
class StockMasters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get assetType => text().withDefault(const Constant('Aktie'))();
  TextColumn get symbol => text()();
  TextColumn get isin => text().withDefault(const Constant(''))();
  TextColumn get wkn => text().withDefault(const Constant(''))();
  TextColumn get instrumentSubtype => text().withDefault(const Constant(''))();
  TextColumn get positionDirection => text().withDefault(const Constant(''))();
  TextColumn get issuer => text().withDefault(const Constant(''))();
  TextColumn get underlying => text().withDefault(const Constant(''))();
  TextColumn get instrumentCurrency =>
      text().withDefault(const Constant('EUR'))();
  RealColumn get nominalValue => real().withDefault(const Constant(0))();
  RealColumn get couponRate => real().withDefault(const Constant(0))();
  DateTimeColumn get maturityDate => dateTime().nullable()();
  RealColumn get strikePrice => real().withDefault(const Constant(0))();
  RealColumn get knockOutBarrier => real().withDefault(const Constant(0))();
  RealColumn get leverage => real().withDefault(const Constant(0))();
  RealColumn get subscriptionRatio => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get dividendCurrency =>
      text().withDefault(const Constant('EUR'))();
  TextColumn get country => text().withDefault(const Constant(''))();
  TextColumn get exchange => text().withDefault(const Constant(''))();
  TextColumn get broker => text().withDefault(const Constant(''))();
  TextColumn get sector => text().withDefault(const Constant(''))();
  TextColumn get dividendFrequency =>
      text().withDefault(const Constant('jährlich'))();
  IntColumn get dividendStartMonth =>
      integer().withDefault(const Constant(1))();
  RealColumn get dividendPerShare => real().withDefault(const Constant(0))();
  TextColumn get companyData => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CountryTaxRates extends Table {
  TextColumn get country => text()();
  RealColumn get withholdingTaxRate => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  RealColumn get exchangeRate => real().withDefault(const Constant(1))();
  BoolColumn get allowManualExchangeRate =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get exchangeRateUpdatedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {country};
}

class AssetClasses extends Table {
  TextColumn get name => text()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

class AppConfigurations extends Table {
  TextColumn get id => text()();
  RealColumn get maximumTaxAllowance =>
      real().withDefault(const Constant(1000))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PhysicalAssets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get accountId => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant('Sonstiges'))();
  TextColumn get metalType => text().withDefault(const Constant(''))();
  RealColumn get quantity => real().withDefault(const Constant(1))();
  RealColumn get weightGrams => real().withDefault(const Constant(0))();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();
  RealColumn get currentValue => real().withDefault(const Constant(0))();
  RealColumn get currentPricePerGram => real().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PortfolioSales extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get destinationAccountId => text().nullable()();
  BoolColumn get accountCredited =>
      boolean().withDefault(const Constant(true))();
  TextColumn get sourceCurrency => text().withDefault(const Constant('EUR'))();
  RealColumn get exchangeRate => real().withDefault(const Constant(1))();
  TextColumn get investmentId => text().nullable()();
  TextColumn get physicalAssetId => text().nullable()();
  TextColumn get assetName => text()();
  TextColumn get assetKind => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get pricePerUnit => real()();
  RealColumn get fees => real().withDefault(const Constant(0))();
  RealColumn get proceeds => real()();
  RealColumn get costBasis => real().withDefault(const Constant(0))();
  RealColumn get realizedGain => real().withDefault(const Constant(0))();
  RealColumn get allowanceUsed => real().withDefault(const Constant(0))();
  RealColumn get taxPaid => real().withDefault(const Constant(0))();
  DateTimeColumn get soldAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PortfolioAuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get displayName => text()();
  TextColumn get details => text().withDefault(const Constant(''))();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppErrorLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get source => text()();
  TextColumn get message => text()();
  TextColumn get details => text().withDefault(const Constant(''))();
  TextColumn get stackTrace => text().withDefault(const Constant(''))();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StockPrices extends Table {
  TextColumn get stockId => text().references(StockMasters, #id)();
  RealColumn get price => real()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  DateTimeColumn get quotedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {stockId};
}

class StockDividends extends Table {
  TextColumn get id => text()();
  TextColumn get stockId => text().references(StockMasters, #id)();
  DateTimeColumn get exDate => dateTime()();
  DateTimeColumn get paymentDate => dateTime().nullable()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MarketDataRefreshes extends Table {
  TextColumn get dataType => text()();
  TextColumn get scopeKey => text()();
  DateTimeColumn get refreshedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {dataType, scopeKey};
}

class ApiRequestDays extends Table {
  TextColumn get day => text()();
  IntColumn get requestCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {day};
}

@DataClassName('LedgerEntry')
class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get bookingDate => dateTime()();
  // The month this payment economically belongs to. This can differ from the
  // booking month, e.g. August salary paid at the end of July.
  DateTimeColumn get budgetMonth => dateTime().nullable()();
  RealColumn get amount => real()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  TextColumn get category => text()();
  TextColumn get merchant => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get paymentMethod => text().withDefault(const Constant(''))();
  TextColumn get recurrenceId => text().withDefault(const Constant(''))();
  TextColumn get sourceType => text().withDefault(const Constant('manual'))();
  TextColumn get sourceId => text().withDefault(const Constant(''))();
  TextColumn get vehicleId => text().withDefault(const Constant(''))();
  TextColumn get accountId => text().withDefault(const Constant(''))();
  BoolColumn get accountApplied =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MasterData extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get kind => text()();
  TextColumn get value => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {userId, kind, value},
  ];
}

@DataClassName('AppReminder')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get title => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get ledgerEntryId => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get vehicleType => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  TextColumn get licensePlate => text().withDefault(const Constant(''))();
  IntColumn get year => integer()();
  TextColumn get fuelType => text().withDefault(const Constant('Benzin'))();
  RealColumn get tankCapacity => real().withDefault(const Constant(0))();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();
  RealColumn get currentValue => real().withDefault(const Constant(0))();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class VehicleCosts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  DateTimeColumn get bookingDate => dateTime()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  RealColumn get odometer => real().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class UserPreferences extends Table {
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get themeMode => text().withDefault(const Constant('dark'))();
  TextColumn get locale => text().withDefault(const Constant('de'))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get dateFormat =>
      text().withDefault(const Constant('dd.MM.yyyy'))();
  BoolColumn get serverMode => boolean().withDefault(const Constant(false))();
  TextColumn get serverUrl => text().withDefault(const Constant(''))();
  IntColumn get serverPort => integer().withDefault(const Constant(443))();
  TextColumn get serverUsername => text().withDefault(const Constant(''))();
  TextColumn get selectedHouseholdAccountId =>
      text().withDefault(const Constant(''))();
  TextColumn get selectedPortfolioAccountId =>
      text().withDefault(const Constant(''))();
  RealColumn get taxAllowance => real().withDefault(const Constant(1000))();
  RealColumn get defaultInvestmentFee =>
      real().withDefault(const Constant(0))();
  BoolColumn get includePhysicalAssetsInTaxAllowance =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dataFilePath => text().withDefault(const Constant(''))();
  RealColumn get freedomAge => real().withDefault(const Constant(35))();
  RealColumn get freedomStartCapital =>
      real().withDefault(const Constant(50000))();
  BoolColumn get freedomUsePortfolio =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

class NetWorthSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get capturedAt => dateTime()();
  RealColumn get accountBalance => real()();
  RealColumn get portfolioValue => real()();
  RealColumn get totalNetWorth => real()();
  RealColumn get vehicleValue => real().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Users,
    Accounts,
    AccountBalanceHistories,
    Investments,
    InvestmentPurchases,
    DividendSchedules,
    LedgerEntries,
    MasterData,
    Reminders,
    Vehicles,
    VehicleCosts,
    UserPreferences,
    NetWorthSnapshots,
    StockMasters,
    StockPrices,
    StockDividends,
    MarketDataRefreshes,
    ApiRequestDays,
    CountryTaxRates,
    AssetClasses,
    AppConfigurations,
    PhysicalAssets,
    PortfolioSales,
    PortfolioAuditLogs,
    AppErrorLogs,
  ],
)
final class AppDatabase extends _$AppDatabase {
  static const _uuid = Uuid();
  final Map<String, List<int>> _dataFileKeys = {};
  final Map<String, BackupKey> _backupKeys = {};
  final Map<String, Timer> _pendingPersists = {};
  final Map<String, BackupStatus> _backupStatus = {};
  final _backupStatusChanges = StreamController<String>.broadcast();

  /// Delay that bundles several quick changes into one data file write.
  static const persistDelay = Duration(seconds: 3);
  AppDatabase()
    : super(
        driftDatabase(
          name: 'wealthflow',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  AppDatabase.forTesting(super.executor);

  void setDataFileKey(String userId, List<int> key) {
    _dataFileKeys[userId] = List<int>.unmodifiable(key);
  }

  void clearDataFileKey(String userId) {
    _dataFileKeys.remove(userId);
    _backupKeys.remove(userId);
    _pendingPersists.remove(userId)?.cancel();
  }

  /// Password-derived key for the data file; null keeps the device key.
  void setBackupKey(String userId, BackupKey? key) {
    if (key == null) {
      _backupKeys.remove(userId);
    } else {
      _backupKeys[userId] = key;
    }
    _backupStatusChanges.add(userId);
  }

  bool hasBackupKey(String userId) => _backupKeys.containsKey(userId);

  @override
  Future<void> close() async {
    for (final timer in _pendingPersists.values) {
      timer.cancel();
    }
    _pendingPersists.clear();
    await _backupStatusChanges.close();
    return super.close();
  }

  Stream<BackupStatus?> watchBackupStatus(String userId) async* {
    yield _backupStatus[userId];
    yield* _backupStatusChanges.stream
        .where((changed) => changed == userId)
        .map((_) => _backupStatus[userId]);
  }

  void _schedulePersist(String userId) {
    if (!_dataFileKeys.containsKey(userId)) return;
    _pendingPersists.remove(userId)?.cancel();
    _pendingPersists[userId] = Timer(persistDelay, () {
      _pendingPersists.remove(userId);
      unawaited(persistUserFile(userId));
    });
  }

  /// Writes a pending data file update right away, e.g. before logout or
  /// when the app goes to the background.
  Future<void> flushPendingPersist(String userId) async {
    final pending = _pendingPersists.remove(userId);
    if (pending == null) return;
    pending.cancel();
    await persistUserFile(userId);
  }

  /// Decrypts a data file. Password-protected files use the stored backup key
  /// when it matches, otherwise [password]; throws [BackupPasswordRequired]
  /// when neither is available.
  Future<Map<String, dynamic>> decodeUserDataFile(
    String userId,
    String content, {
    String? password,
  }) async {
    final String clear;
    if (DataCipher.isPasswordProtected(content)) {
      clear = await DataCipher.decryptWithPassword(
        content,
        stored: _backupKeys[userId],
        password: password,
      );
    } else {
      final key = _dataFileKeys[userId];
      clear = key == null ? content : await DataCipher.decrypt(content, key);
    }
    final decoded = jsonDecode(clear);
    if (decoded is! Map) throw const FormatException('Ungültige Datendatei');
    return Map<String, dynamic>.from(decoded);
  }

  @override
  int get schemaVersion => 19;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedAssetClasses();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(ledgerEntries, ledgerEntries.recurrenceId);
        await migrator.addColumn(ledgerEntries, ledgerEntries.sourceType);
        await migrator.addColumn(ledgerEntries, ledgerEntries.sourceId);
        await migrator.addColumn(ledgerEntries, ledgerEntries.vehicleId);
      }
      if (from < 3) {
        await migrator.addColumn(ledgerEntries, ledgerEntries.accountId);
        await migrator.createTable(masterData);
      }
      if (from < 4) {
        await migrator.addColumn(ledgerEntries, ledgerEntries.accountApplied);
      }
      if (from < 5) {
        await migrator.addColumn(ledgerEntries, ledgerEntries.budgetMonth);
        await migrator.addColumn(masterData, masterData.updatedAt);
        await migrator.addColumn(masterData, masterData.deletedAt);
        await migrator.addColumn(
          userPreferences,
          userPreferences.selectedHouseholdAccountId,
        );
        await migrator.addColumn(userPreferences, userPreferences.dataFilePath);
        await migrator.addColumn(userPreferences, userPreferences.freedomAge);
        await migrator.addColumn(
          userPreferences,
          userPreferences.freedomStartCapital,
        );
        await migrator.addColumn(
          userPreferences,
          userPreferences.freedomUsePortfolio,
        );
        await migrator.addColumn(userPreferences, userPreferences.lastSyncAt);
        await migrator.createTable(dividendSchedules);
        await migrator.createTable(netWorthSnapshots);
      }
      if (from < 6) {
        await migrator.createTable(investmentPurchases);
        await customStatement(
          'INSERT INTO investment_purchases '
          '(id, user_id, investment_id, purchase_date, purchase_price, quantity, fees, created_at) '
          "SELECT id || '-initial', user_id, id, purchase_date, purchase_price, quantity, fees, created_at "
          'FROM investments WHERE deleted_at IS NULL',
        );
      }
      if (from < 7) {
        await migrator.addColumn(users, users.role);
        await migrator.addColumn(investments, investments.stockId);
        await migrator.addColumn(
          dividendSchedules,
          dividendSchedules.paymentDate,
        );
        await migrator.addColumn(
          dividendSchedules,
          dividendSchedules.paymentYear,
        );
        await migrator.addColumn(dividendSchedules, dividendSchedules.currency);
        await migrator.createTable(stockMasters);
        await migrator.createTable(stockPrices);
        await migrator.createTable(stockDividends);
        await migrator.createTable(marketDataRefreshes);
        await migrator.createTable(apiRequestDays);
      }
      if (from < 8) {
        await migrator.addColumn(investments, investments.dividendStartMonth);
        await migrator.createTable(reminders);
      }
      if (from < 9) {
        await migrator.addColumn(investments, investments.dividendCurrency);
        await migrator.addColumn(investments, investments.dividendExchangeRate);
        await migrator.addColumn(
          investments,
          investments.dividendWithholdingTaxRate,
        );
        await migrator.addColumn(
          dividendSchedules,
          dividendSchedules.exchangeRate,
        );
        await migrator.addColumn(
          dividendSchedules,
          dividendSchedules.withholdingTaxRate,
        );
      }
      if (from < 10) {
        await migrator.addColumn(accounts, accounts.usageType);
        await migrator.addColumn(investments, investments.accountId);
        await migrator.addColumn(vehicles, vehicles.purchasePrice);
        await migrator.addColumn(vehicles, vehicles.currentValue);
        await migrator.addColumn(
          userPreferences,
          userPreferences.selectedPortfolioAccountId,
        );
        await migrator.addColumn(userPreferences, userPreferences.taxAllowance);
        await migrator.createTable(countryTaxRates);
        await migrator.createTable(appConfigurations);
        await migrator.createTable(physicalAssets);
        await migrator.createTable(appErrorLogs);
        await customStatement(
          'UPDATE investments SET dividend_withholding_tax_rate = 15 '
          "WHERE lower(trim(country)) IN ('usa', 'us', 'united states', "
          "'vereinigte staaten') AND dividend_withholding_tax_rate = 0",
        );
        await customStatement(
          'UPDATE dividend_schedules SET withholding_tax_rate = 15 '
          'WHERE withholding_tax_rate = 0 AND investment_id IN '
          '(SELECT id FROM investments WHERE lower(trim(country)) IN '
          "('usa', 'us', 'united states', 'vereinigte staaten'))",
        );
        await customStatement(
          "UPDATE user_preferences SET theme_mode = 'dark' "
          "WHERE theme_mode = 'system'",
        );
      }
      if (from < 11) {
        await migrator.addColumn(accounts, accounts.displayOrder);
        await migrator.addColumn(stockMasters, stockMasters.wkn);
        await migrator.addColumn(stockMasters, stockMasters.dividendCurrency);
        await migrator.addColumn(stockMasters, stockMasters.broker);
        await migrator.addColumn(stockMasters, stockMasters.dividendFrequency);
        await migrator.addColumn(stockMasters, stockMasters.dividendStartMonth);
        await migrator.addColumn(physicalAssets, physicalAssets.metalType);
        await migrator.addColumn(physicalAssets, physicalAssets.weightGrams);
        await migrator.addColumn(physicalAssets, physicalAssets.purchaseDate);
        await customStatement(
          'UPDATE stock_masters SET dividend_currency = currency '
          "WHERE dividend_currency = 'EUR' AND currency != 'EUR'",
        );
        await customStatement(
          'UPDATE accounts SET display_order = rowid WHERE display_order = 0',
        );
      }
      if (from < 12) {
        await migrator.addColumn(
          investmentPurchases,
          investmentPurchases.updatedAt,
        );
        await migrator.addColumn(
          investmentPurchases,
          investmentPurchases.deletedAt,
        );
        await migrator.addColumn(
          physicalAssets,
          physicalAssets.currentPricePerGram,
        );
        await migrator.addColumn(
          userPreferences,
          userPreferences.defaultInvestmentFee,
        );
        await migrator.createTable(portfolioSales);
        await migrator.createTable(portfolioAuditLogs);
        await customStatement(
          'UPDATE physical_assets SET current_price_per_gram = '
          'CASE WHEN weight_grams > 0 THEN current_value / weight_grams ELSE 0 END',
        );
      }
      if (from < 13) {
        await migrator.addColumn(
          userPreferences,
          userPreferences.includePhysicalAssetsInTaxAllowance,
        );
      }
      if (from < 14) {
        await migrator.addColumn(countryTaxRates, countryTaxRates.currency);
        await migrator.addColumn(countryTaxRates, countryTaxRates.exchangeRate);
        await migrator.addColumn(
          countryTaxRates,
          countryTaxRates.allowManualExchangeRate,
        );
        await migrator.addColumn(
          countryTaxRates,
          countryTaxRates.exchangeRateUpdatedAt,
        );
        await migrator.createTable(assetClasses);
        await migrator.addColumn(
          portfolioSales,
          portfolioSales.destinationAccountId,
        );
        await migrator.addColumn(
          portfolioSales,
          portfolioSales.accountCredited,
        );
        await migrator.addColumn(portfolioSales, portfolioSales.sourceCurrency);
        await migrator.addColumn(portfolioSales, portfolioSales.exchangeRate);
        await _seedAssetClasses();
      }
      if (from < 15) {
        await migrator.addColumn(vehicles, vehicles.purchaseDate);
        await customStatement(
          'UPDATE vehicles SET purchase_date = created_at '
          'WHERE purchase_date IS NULL',
        );
      }
      if (from < 16) {
        await migrator.createTable(accountBalanceHistories);
        await migrator.addColumn(
          investmentPurchases,
          investmentPurchases.cashApplied,
        );
      }
      if (from < 17) {
        await migrator.addColumn(investments, investments.instrumentSubtype);
        await migrator.addColumn(investments, investments.positionDirection);
        await migrator.addColumn(investments, investments.issuer);
        await migrator.addColumn(investments, investments.underlying);
        await migrator.addColumn(investments, investments.instrumentCurrency);
        await migrator.addColumn(investments, investments.nominalValue);
        await migrator.addColumn(investments, investments.couponRate);
        await migrator.addColumn(investments, investments.maturityDate);
        await migrator.addColumn(investments, investments.strikePrice);
        await migrator.addColumn(investments, investments.knockOutBarrier);
        await migrator.addColumn(investments, investments.leverage);
        await migrator.addColumn(investments, investments.subscriptionRatio);
      }
      if (from < 18) {
        // Recreate the catalogue once to remove the former global UNIQUE
        // constraint on symbol. Empty symbols are valid for bonds and
        // derivatives, while identity is now determined per asset class.
        await customStatement(
          'CREATE TABLE stock_prices_v17_cache AS '
          'SELECT stock_id, price, currency, quoted_at FROM stock_prices',
        );
        await customStatement(
          'CREATE TABLE stock_dividends_v17_cache AS '
          'SELECT id, stock_id, ex_date, payment_date, amount, currency, '
          'fetched_at FROM stock_dividends',
        );
        await customStatement('DROP TABLE stock_prices');
        await customStatement('DROP TABLE stock_dividends');
        await customStatement(
          'ALTER TABLE stock_masters RENAME TO stock_masters_v17',
        );
        await migrator.createTable(stockMasters);
        await customStatement(
          'INSERT INTO stock_masters '
          '(id, name, asset_type, symbol, isin, wkn, currency, '
          'dividend_currency, country, exchange, broker, sector, '
          'dividend_frequency, dividend_start_month, company_data, '
          'created_at, updated_at, deleted_at) '
          "SELECT id, name, 'Aktie', symbol, isin, wkn, currency, "
          'dividend_currency, country, exchange, broker, sector, '
          'dividend_frequency, dividend_start_month, company_data, '
          'created_at, updated_at, deleted_at FROM stock_masters_v17',
        );
        await customStatement(
          'UPDATE stock_masters SET asset_type = COALESCE('
          '(SELECT asset_type FROM investments '
          'WHERE investments.stock_id = stock_masters.id '
          'ORDER BY investments.created_at LIMIT 1), asset_type)',
        );
        await customStatement('DROP TABLE stock_masters_v17');
        await migrator.createTable(stockPrices);
        await migrator.createTable(stockDividends);
        await customStatement(
          'INSERT INTO stock_prices (stock_id, price, currency, quoted_at) '
          'SELECT stock_id, price, currency, quoted_at '
          'FROM stock_prices_v17_cache',
        );
        await customStatement(
          'INSERT INTO stock_dividends '
          '(id, stock_id, ex_date, payment_date, amount, currency, fetched_at) '
          'SELECT id, stock_id, ex_date, payment_date, amount, currency, '
          'fetched_at FROM stock_dividends_v17_cache',
        );
        await customStatement('DROP TABLE stock_prices_v17_cache');
        await customStatement('DROP TABLE stock_dividends_v17_cache');
        await _backfillCountryCurrencies();
        await _seedAssetClasses();
      }
      if (from < 19) {
        final stockMasterColumns = await customSelect(
          "PRAGMA table_info('stock_masters')",
        ).get();
        if (!stockMasterColumns.any(
          (row) => row.data['name'] == 'dividend_per_share',
        )) {
          await migrator.addColumn(stockMasters, stockMasters.dividendPerShare);
        }
        final snapshotColumns = await customSelect(
          "PRAGMA table_info('net_worth_snapshots')",
        ).get();
        if (snapshotColumns.isEmpty) {
          await migrator.createTable(netWorthSnapshots);
        } else if (!snapshotColumns.any(
          (row) => row.data['name'] == 'vehicle_value',
        )) {
          await migrator.addColumn(
            netWorthSnapshots,
            netWorthSnapshots.vehicleValue,
          );
        }
      }
    },
  );

  Future<void> _backfillCountryCurrencies() async {
    final rows = await select(countryTaxRates).get();
    final countries = <String>[
      ...rows.map((row) => row.country),
      ...(await select(stockMasters).get()).map((row) => row.country),
      ...(await (select(
        masterData,
      )..where((row) => row.kind.equals('country'))).get()).map(
        (row) => row.value,
      ),
    ].where((value) => value.trim().isNotEmpty);
    final known = <String, CountryTaxRate>{
      for (final row in rows) normalizeCountry(row.country): row,
    };
    final uniqueCountries = <String, String>{};
    for (final country in countries) {
      uniqueCountries.putIfAbsent(
        normalizeCountry(country),
        () => country.trim(),
      );
    }
    for (final entry in uniqueCountries.entries) {
      final row = known[entry.key];
      final inferred = defaultCurrencyForCountry(entry.value);
      if (row == null) {
        await into(countryTaxRates).insert(
          CountryTaxRatesCompanion.insert(
            country: entry.value,
            withholdingTaxRate: Value(
              const {
                    'usa',
                    'us',
                    'united states',
                    'vereinigte staaten',
                  }.contains(entry.key)
                  ? 15
                  : 0,
            ),
            currency: Value(inferred),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      } else if (row.currency.toUpperCase() == 'EUR' && inferred != 'EUR') {
        await (update(
          countryTaxRates,
        )..where((table) => table.country.equals(row.country))).write(
          CountryTaxRatesCompanion(
            currency: Value(inferred),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    }
  }

  Future<void> _seedAssetClasses() => batch((batch) {
    for (final entry in supportedPortfolioAssetClasses.indexed) {
      batch.insert(
        assetClasses,
        AssetClassesCompanion.insert(
          name: entry.$2,
          displayOrder: Value(entry.$1),
          createdAt: DateTime.now().toUtc(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  });

  Future<User?> userByEmail(String email) => (select(
    users,
  )..where((row) => row.email.equals(email.toLowerCase()))).getSingleOrNull();

  Future<User?> userById(String id) =>
      (select(users)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<void> createUser(UsersCompanion user) => into(users).insert(user);

  Future<int> userCount() async {
    final count = users.id.count();
    final row = await (selectOnly(users)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Stream<List<User>> watchUsers() => (select(
    users,
  )..orderBy([(row) => OrderingTerm.asc(row.displayName)])).watch();

  Future<void> updateUserRole({
    required String actorUserId,
    required String userId,
    required String role,
  }) async {
    await _requireAdmin(actorUserId);
    if (!const {'admin', 'member'}.contains(role)) {
      throw ArgumentError.value(role, 'role', 'Unbekannte Rolle');
    }
    if (actorUserId == userId && role != 'admin') {
      throw StateError('Administratoren können sich nicht selbst herabstufen.');
    }
    await (update(users)..where((row) => row.id.equals(userId))).write(
      UsersCompanion(
        role: Value(role),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<StockMaster>> watchStockMasters() =>
      (select(stockMasters)
            ..where((row) => row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Future<List<StockMaster>> stockPool() =>
      (select(stockMasters)..where((row) => row.deletedAt.isNull())).get();

  String _stockMasterIdentity(StockMaster stock) => portfolioMasterIdentity(
    assetType: stock.assetType,
    name: stock.name,
    symbol: stock.symbol,
    isin: stock.isin,
    wkn: stock.wkn,
    instrumentSubtype: stock.instrumentSubtype,
    issuer: stock.issuer,
    underlying: stock.underlying,
    maturityDate: stock.maturityDate,
  );

  String _companionStockMasterIdentity(StockMastersCompanion value) =>
      portfolioMasterIdentity(
        assetType: value.assetType.present ? value.assetType.value : 'Aktie',
        name: value.name.value,
        symbol: value.symbol.value,
        isin: value.isin.present ? value.isin.value : '',
        wkn: value.wkn.present ? value.wkn.value : '',
        instrumentSubtype: value.instrumentSubtype.present
            ? value.instrumentSubtype.value
            : '',
        issuer: value.issuer.present ? value.issuer.value : '',
        underlying: value.underlying.present ? value.underlying.value : '',
        maturityDate: value.maturityDate.present
            ? value.maturityDate.value
            : null,
      );

  String? _validateStockMasterCompanion(StockMastersCompanion value) =>
      portfolioMasterValidationError(
        assetType: value.assetType.present ? value.assetType.value : 'Aktie',
        name: value.name.value,
        country: value.country.present ? value.country.value : '',
        symbol: value.symbol.value,
        isin: value.isin.present ? value.isin.value : '',
        wkn: value.wkn.present ? value.wkn.value : '',
        instrumentSubtype: value.instrumentSubtype.present
            ? value.instrumentSubtype.value
            : '',
        issuer: value.issuer.present ? value.issuer.value : '',
        underlying: value.underlying.present ? value.underlying.value : '',
      );

  Future<StockMaster?> _matchingStockMaster(
    StockMastersCompanion value, {
    String? excludingId,
  }) async {
    final identity = _companionStockMasterIdentity(value);
    final items = await stockPool();
    return items
        .where(
          (item) =>
              item.id != excludingId && _stockMasterIdentity(item) == identity,
        )
        .firstOrNull;
  }

  Future<void> saveStockMaster(
    String actorUserId,
    StockMastersCompanion value,
  ) async {
    await _requireAdmin(actorUserId);
    final validationError = _validateStockMasterCompanion(value);
    if (validationError != null) throw ArgumentError(validationError);
    if (await _matchingStockMaster(value, excludingId: value.id.value) !=
        null) {
      throw StateError(
        'Ein Portfolio-Stammdatensatz mit dieser Identität existiert bereits.',
      );
    }
    await transaction(() async {
      await into(stockMasters).insertOnConflictUpdate(value);
      final stock = await (select(
        stockMasters,
      )..where((row) => row.id.equals(value.id.value))).getSingle();
      final rates = await select(countryTaxRates).get();
      final normalizedCountry = stock.country.trim().toLowerCase();
      final countryConfiguration = rates
          .where(
            (rate) => rate.country.trim().toLowerCase() == normalizedCountry,
          )
          .firstOrNull;
      final savedDividendCurrency = stock.dividendCurrency.toUpperCase();
      final configuredRate = countryConfiguration?.withholdingTaxRate;
      final fallbackRate =
          const {
            'usa',
            'us',
            'united states',
            'vereinigte staaten',
          }.contains(normalizedCountry)
          ? 15.0
          : 0.0;
      await (update(investments)..where(
            (row) => row.stockId.equals(stock.id) & row.deletedAt.isNull(),
          ))
          .write(
            InvestmentsCompanion(
              name: Value(stock.name),
              assetType: Value(stock.assetType),
              symbol: Value(stock.symbol),
              isin: Value(stock.isin),
              wkn: Value(stock.wkn),
              instrumentSubtype: Value(stock.instrumentSubtype),
              positionDirection: Value(stock.positionDirection),
              issuer: Value(stock.issuer),
              underlying: Value(stock.underlying),
              instrumentCurrency: Value(stock.instrumentCurrency),
              nominalValue: Value(stock.nominalValue),
              couponRate: Value(stock.couponRate),
              maturityDate: Value(stock.maturityDate),
              strikePrice: Value(stock.strikePrice),
              knockOutBarrier: Value(stock.knockOutBarrier),
              leverage: Value(stock.leverage),
              subscriptionRatio: Value(stock.subscriptionRatio),
              broker: Value(stock.broker),
              country: Value(stock.country),
              sector: Value(stock.sector),
              dividendCurrency: Value(savedDividendCurrency),
              annualDividend: Value(stock.dividendPerShare),
              dividendFrequency: Value(stock.dividendFrequency),
              dividendStartMonth: Value(stock.dividendStartMonth),
              dividendWithholdingTaxRate: Value(configuredRate ?? fallbackRate),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
  }

  /// Creates a catalogue record from a position if its class-specific
  /// identity is not known yet. Existing records are returned unchanged.
  Future<StockMaster> ensurePortfolioMaster(
    String actorUserId,
    StockMastersCompanion value,
  ) async {
    if (await userById(actorUserId) == null) {
      throw StateError('Unbekannter Benutzer.');
    }
    final validationError = _validateStockMasterCompanion(value);
    if (validationError != null) throw ArgumentError(validationError);
    return transaction(() async {
      final existing = await _matchingStockMaster(value);
      if (existing != null) return existing;
      await into(stockMasters).insert(value);
      return (select(
        stockMasters,
      )..where((row) => row.id.equals(value.id.value))).getSingle();
    });
  }

  Future<void> deleteStockMaster(String actorUserId, String id) async {
    await _requireAdmin(actorUserId);
    await (update(stockMasters)..where((row) => row.id.equals(id))).write(
      StockMastersCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> _requireAdmin(String userId) async {
    final actor = await userById(userId);
    if (actor?.role != 'admin') {
      throw StateError('Für diese Aktion ist die Adminrolle erforderlich.');
    }
  }

  Stream<List<CountryTaxRate>> watchCountryTaxRates() => (select(
    countryTaxRates,
  )..orderBy([(row) => OrderingTerm.asc(row.country)])).watch();

  Future<List<CountryTaxRate>> countryExchangePool() => (select(
    countryTaxRates,
  )..orderBy([(row) => OrderingTerm.asc(row.country)])).get();

  Stream<List<AssetClassesData>> watchAssetClasses() =>
      (select(assetClasses)..orderBy([
            (row) => OrderingTerm.asc(row.displayOrder),
            (row) => OrderingTerm.asc(row.name),
          ]))
          .watch();

  Future<void> saveAssetClass({
    required String actorUserId,
    required String name,
  }) async {
    await _requireAdmin(actorUserId);
    final normalized = name.trim();
    if (!supportedPortfolioAssetClasses.contains(normalized)) {
      throw StateError('Die Portfolio-Anlageklassen sind fest vorgegeben.');
    }
    await _seedAssetClasses();
  }

  Future<void> deleteAssetClass({
    required String actorUserId,
    required String name,
  }) async {
    await _requireAdmin(actorUserId);
    throw StateError('Die Portfolio-Anlageklassen sind fest vorgegeben.');
  }

  Future<List<String>> availableCountries() async {
    final values = <String>[];
    values.addAll(
      (await (select(masterData)..where(
                (row) => row.kind.equals('country') & row.deletedAt.isNull(),
              ))
              .get())
          .map((row) => row.value.trim()),
    );
    values.addAll(
      (await (select(
        stockMasters,
      )..where((row) => row.deletedAt.isNull())).get()).map(
        (row) => row.country.trim(),
      ),
    );
    values.addAll(
      (await select(countryTaxRates).get()).map((row) => row.country.trim()),
    );
    final deduplicated = <String, String>{};
    for (final value in values.where((value) => value.isNotEmpty)) {
      deduplicated.putIfAbsent(normalizeCountry(value), () => value.trim());
    }
    final sorted = deduplicated.values.toList()..sort();
    return sorted;
  }

  Future<void> saveCountryTaxRate({
    required String actorUserId,
    required String country,
    required double rate,
    String? currency,
  }) async {
    await _requireAdmin(actorUserId);
    if (country.trim().isEmpty || rate < 0 || rate > 100) {
      throw ArgumentError('Land und Quellensteuer müssen gültig sein.');
    }
    final normalizedCountry = normalizeCountry(country);
    final existing = (await select(countryTaxRates).get())
        .where((row) => normalizeCountry(row.country) == normalizedCountry)
        .firstOrNull;
    final normalizedCurrency = (currency ?? '').trim().toUpperCase();
    if (normalizedCurrency.isNotEmpty &&
        !isSupportedCurrency(normalizedCurrency)) {
      throw ArgumentError('Nicht unterstützte ISO-Währung.');
    }
    final resolvedCurrency = normalizedCurrency.isNotEmpty
        ? normalizedCurrency
        : existing?.currency.toUpperCase() ??
              defaultCurrencyForCountry(country);
    if (existing == null) {
      await into(countryTaxRates).insert(
        CountryTaxRatesCompanion.insert(
          country: country.trim(),
          withholdingTaxRate: Value(rate),
          currency: Value(resolvedCurrency),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    } else {
      await (update(
        countryTaxRates,
      )..where((row) => row.country.equals(existing.country))).write(
        CountryTaxRatesCompanion(
          withholdingTaxRate: Value(rate),
          currency: Value(resolvedCurrency),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
    final normalized = normalizeCountry(country);
    final affected = (await select(investments).get())
        .where(
          (investment) => investment.country.trim().toLowerCase() == normalized,
        )
        .toList();
    await transaction(() async {
      for (final investment in affected) {
        await (update(
          investments,
        )..where((row) => row.id.equals(investment.id))).write(
          InvestmentsCompanion(
            dividendWithholdingTaxRate: Value(rate),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
        await (update(dividendSchedules)..where(
              (row) =>
                  row.investmentId.equals(investment.id) &
                  row.deletedAt.isNull(),
            ))
            .write(
              DividendSchedulesCompanion(
                withholdingTaxRate: Value(rate),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    });
  }

  Future<void> saveCountryExchangeRate({
    required String actorUserId,
    required String country,
    required String currency,
    required double exchangeRate,
    bool? allowManualExchangeRate,
    bool apiKeyConfigured = false,
  }) async {
    if (country.trim().isEmpty ||
        currency.trim().isEmpty ||
        exchangeRate <= 0) {
      throw ArgumentError('Land, Währung und Wechselkurs müssen gültig sein.');
    }
    if (!isSupportedCurrency(currency)) {
      throw ArgumentError('Nicht unterstützte ISO-Währung.');
    }
    final actor = await userById(actorUserId);
    final existing = (await select(countryTaxRates).get())
        .where(
          (row) =>
              row.country.trim().toLowerCase() == country.trim().toLowerCase(),
        )
        .firstOrNull;
    final isAdmin = actor?.role == 'admin';
    if (!isAdmin &&
        apiKeyConfigured &&
        !(existing?.allowManualExchangeRate ?? true)) {
      throw StateError(
        'Der Wechselkurs ist durch die Administration gesperrt.',
      );
    }
    if (allowManualExchangeRate != null && !isAdmin) {
      throw StateError('Nur Administratoren dürfen die Freigabe ändern.');
    }
    final now = DateTime.now().toUtc();
    if (existing == null) {
      await into(countryTaxRates).insert(
        CountryTaxRatesCompanion.insert(
          country: country.trim(),
          currency: Value(currency.trim().toUpperCase()),
          exchangeRate: Value(exchangeRate),
          allowManualExchangeRate: Value(allowManualExchangeRate ?? true),
          exchangeRateUpdatedAt: Value(now),
          updatedAt: now,
        ),
      );
    } else {
      await (update(
        countryTaxRates,
      )..where((row) => row.country.equals(existing.country))).write(
        CountryTaxRatesCompanion(
          currency: Value(currency.trim().toUpperCase()),
          exchangeRate: Value(exchangeRate),
          allowManualExchangeRate: Value(
            allowManualExchangeRate ?? existing.allowManualExchangeRate,
          ),
          exchangeRateUpdatedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
    final normalized = country.trim().toLowerCase();
    final affected = (await select(investments).get())
        .where((item) => item.country.trim().toLowerCase() == normalized)
        .toList();
    await transaction(() async {
      for (final investment in affected) {
        await (update(
          investments,
        )..where((row) => row.id.equals(investment.id))).write(
          InvestmentsCompanion(
            dividendCurrency: Value(currency.trim().toUpperCase()),
            dividendExchangeRate: Value(exchangeRate),
            updatedAt: Value(now),
          ),
        );
        await (update(dividendSchedules)..where(
              (row) =>
                  row.investmentId.equals(investment.id) &
                  row.deletedAt.isNull(),
            ))
            .write(
              DividendSchedulesCompanion(
                currency: Value(currency.trim().toUpperCase()),
                exchangeRate: Value(exchangeRate),
                updatedAt: Value(now),
              ),
            );
      }
    });
  }

  Stream<AppConfiguration> watchAppConfiguration() async* {
    yield await appConfiguration();
    yield* (select(
      appConfigurations,
    )..where((row) => row.id.equals('global'))).watchSingle();
  }

  Future<AppConfiguration> appConfiguration() async {
    final current = await (select(
      appConfigurations,
    )..where((row) => row.id.equals('global'))).getSingleOrNull();
    if (current != null) return current;
    await into(appConfigurations).insert(
      AppConfigurationsCompanion.insert(
        id: 'global',
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    return (select(
      appConfigurations,
    )..where((row) => row.id.equals('global'))).getSingle();
  }

  Future<void> setMaximumTaxAllowance({
    required String actorUserId,
    required double amount,
  }) async {
    await _requireAdmin(actorUserId);
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'Ungültiger Höchstbetrag');
    }
    await into(appConfigurations).insertOnConflictUpdate(
      AppConfigurationsCompanion.insert(
        id: 'global',
        maximumTaxAllowance: Value(amount),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await customStatement(
      'UPDATE user_preferences SET tax_allowance = ? '
      'WHERE tax_allowance > ?',
      [amount, amount],
    );
  }

  Stream<List<AppErrorLog>> watchErrorLogs() => (select(
    appErrorLogs,
  )..orderBy([(row) => OrderingTerm.desc(row.occurredAt)])).watch();

  Future<void> logError({
    String? userId,
    required String source,
    required Object error,
    StackTrace? stackTrace,
    String details = '',
  }) async {
    try {
      await into(appErrorLogs).insert(
        AppErrorLogsCompanion.insert(
          id: _uuid.v4(),
          userId: Value(userId),
          source: source,
          message: error.toString(),
          details: Value(details),
          stackTrace: Value(stackTrace?.toString() ?? ''),
          occurredAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      // Error reporting must never trigger another application failure.
    }
  }

  Future<void> clearErrorLogs(String actorUserId) async {
    await _requireAdmin(actorUserId);
    await delete(appErrorLogs).go();
  }

  Future<StockPrice?> stockPrice(String stockId) => (select(
    stockPrices,
  )..where((row) => row.stockId.equals(stockId))).getSingleOrNull();

  Future<void> saveStockPrice(StockPricesCompanion value) async {
    await transaction(() async {
      await into(stockPrices).insertOnConflictUpdate(value);
      await (update(
        investments,
      )..where((row) => row.stockId.equals(value.stockId.value))).write(
        InvestmentsCompanion(
          currentPrice: Value(value.price.value),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    });
  }

  Future<DateTime?> lastMarketRefresh(String type, String scope) async =>
      (await (select(marketDataRefreshes)..where(
                (row) => row.dataType.equals(type) & row.scopeKey.equals(scope),
              ))
              .getSingleOrNull())
          ?.refreshedAt;

  Future<void> markMarketRefresh(String type, String scope, DateTime at) =>
      into(marketDataRefreshes).insertOnConflictUpdate(
        MarketDataRefreshesCompanion.insert(
          dataType: type,
          scopeKey: scope,
          refreshedAt: at,
        ),
      );

  Future<int> apiRequestsForDay(String day) async =>
      (await (select(
            apiRequestDays,
          )..where((row) => row.day.equals(day))).getSingleOrNull())
          ?.requestCount ??
      0;

  Future<void> recordApiRequest(String day) async {
    final current = await apiRequestsForDay(day);
    await into(apiRequestDays).insertOnConflictUpdate(
      ApiRequestDaysCompanion.insert(
        day: day,
        requestCount: Value(current + 1),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<List<StockDividend>> stockDividendsForYear(String stockId, int year) =>
      (select(stockDividends)..where(
            (row) =>
                row.stockId.equals(stockId) &
                row.exDate.isBiggerOrEqualValue(DateTime(year)) &
                row.exDate.isSmallerThanValue(DateTime(year + 1)),
          ))
          .get();

  Future<void> saveStockDividends(Iterable<StockDividendsCompanion> values) =>
      batch((batch) {
        for (final value in values) {
          batch.insert(stockDividends, value, mode: InsertMode.insertOrReplace);
        }
      });

  Future<void> updateUserPassword(String userId, String hash, String salt) =>
      (update(users)..where((row) => row.id.equals(userId))).write(
        UsersCompanion(
          passwordHash: Value(hash),
          passwordSalt: Value(salt),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  /// Books entries whose date has arrived since the app was opened.
  Future<void> applyDueLedgerEntries(String userId) async {
    if (await _applyDueLedgerEntries(userId)) {
      await captureNetWorth(userId);
    }
  }

  Stream<List<Account>> watchAccounts(String userId) async* {
    if (await _applyDueLedgerEntries(userId)) {
      await captureNetWorth(userId);
    }
    yield* (select(accounts)
          ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
          ..orderBy([
            (row) => OrderingTerm.asc(row.displayOrder),
            (row) => OrderingTerm.asc(row.label),
          ]))
        .watch();
  }

  Stream<List<AccountBalanceHistory>> watchAccountBalanceHistories(
    String userId,
  ) =>
      (select(accountBalanceHistories)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.effectiveAt)]))
          .watch();

  Future<void> saveAccount(
    AccountsCompanion value, {
    DateTime? balanceEffectiveAt,
  }) async {
    final old = await (select(
      accounts,
    )..where((row) => row.id.equals(value.id.value))).getSingleOrNull();
    if (old != null && value.usageType.present) {
      final requested = value.usageType.value;
      if (old.usageType != 'unassigned' && requested != old.usageType) {
        throw StateError(
          'Die Verwendung eines bereits zugeordneten Kontos kann nicht geändert werden.',
        );
      }
      if (requested != 'unassigned' &&
          !await accountCanBeUsed(old.userId, old.id, requested)) {
        throw StateError('Das Konto enthält Daten aus einem anderen Modul.');
      }
    }
    var valueToSave = value;
    if (old == null && !value.displayOrder.present) {
      final siblings =
          await (select(accounts)..where(
                (row) =>
                    row.userId.equals(value.userId.value) &
                    row.deletedAt.isNull(),
              ))
              .get();
      final nextOrder =
          siblings.fold<int>(
            0,
            (maximum, account) =>
                account.displayOrder > maximum ? account.displayOrder : maximum,
          ) +
          1;
      valueToSave = value.copyWith(displayOrder: Value(nextOrder));
    }
    await transaction(() async {
      await into(accounts).insertOnConflictUpdate(valueToSave);
      if (balanceEffectiveAt != null) {
        final saved = await (select(
          accounts,
        )..where((row) => row.id.equals(value.id.value))).getSingle();
        await into(accountBalanceHistories).insert(
          AccountBalanceHistoriesCompanion.insert(
            id: _uuid.v4(),
            userId: saved.userId,
            accountId: saved.id,
            effectiveAt: balanceEffectiveAt,
            balance: saved.balance,
            availableBalance: saved.availableBalance,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }
    });
    await captureNetWorth(value.userId.value);
  }

  Future<void> saveAccountBalanceHistory({
    required String userId,
    required String accountId,
    required DateTime effectiveAt,
    required double balance,
    required double availableBalance,
  }) async {
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(accountId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null) throw StateError('Das Konto wurde nicht gefunden.');
    await transaction(() async {
      await into(accountBalanceHistories).insert(
        AccountBalanceHistoriesCompanion.insert(
          id: _uuid.v4(),
          userId: userId,
          accountId: accountId,
          effectiveAt: effectiveAt,
          balance: balance,
          availableBalance: availableBalance,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      if (!effectiveAt.isAfter(DateTime.now())) {
        await (update(
          accounts,
        )..where((row) => row.id.equals(accountId))).write(
          AccountsCompanion(
            balance: Value(balance),
            availableBalance: Value(availableBalance),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });
    await captureNetWorth(userId);
  }

  Future<void> deleteAccountBalanceHistory(String id, String userId) async {
    await (update(
      accountBalanceHistories,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      AccountBalanceHistoriesCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }

  Future<void> reorderAccounts(String userId, List<String> accountIds) async {
    await transaction(() async {
      for (final indexed in accountIds.indexed) {
        await (update(accounts)..where(
              (row) => row.id.equals(indexed.$2) & row.userId.equals(userId),
            ))
            .write(
              AccountsCompanion(
                displayOrder: Value(indexed.$1 + 1),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    });
    _schedulePersist(userId);
  }

  Future<void> selectAccountForUsage({
    required String userId,
    required String accountId,
    required String usageType,
  }) async {
    if (!const {'household', 'portfolio'}.contains(usageType)) {
      throw ArgumentError.value(usageType, 'usageType');
    }
    await transaction(() async {
      final account =
          await (select(accounts)..where(
                (row) =>
                    row.id.equals(accountId) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (account == null) throw StateError('Das Konto ist nicht verfügbar.');
      if (account.usageType != 'unassigned' && account.usageType != usageType) {
        throw StateError(
          'Das Konto wird bereits in einem anderen Modul verwendet.',
        );
      }
      final hasLedger =
          await (select(ledgerEntries)
                ..limit(1)
                ..where(
                  (row) =>
                      row.userId.equals(userId) &
                      row.accountId.equals(accountId) &
                      row.deletedAt.isNull(),
                ))
              .getSingleOrNull() !=
          null;
      final hasPortfolio =
          await (select(investments)
                    ..limit(1)
                    ..where(
                      (row) =>
                          row.userId.equals(userId) &
                          row.accountId.equals(accountId) &
                          row.deletedAt.isNull(),
                    ))
                  .getSingleOrNull() !=
              null ||
          await (select(physicalAssets)
                    ..limit(1)
                    ..where(
                      (row) =>
                          row.userId.equals(userId) &
                          row.accountId.equals(accountId) &
                          row.deletedAt.isNull(),
                    ))
                  .getSingleOrNull() !=
              null;
      if (usageType == 'portfolio' && hasLedger) {
        throw StateError(
          'Konten mit Haushaltsbuchungen können keinem Portfolio zugeordnet werden.',
        );
      }
      if (usageType == 'household' && hasPortfolio) {
        throw StateError(
          'Konten mit Portfolio-Daten können keinem Haushaltsbuch zugeordnet werden.',
        );
      }
      await (update(accounts)..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          usageType: Value(usageType),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      if (usageType == 'portfolio') {
        await (update(investments)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.accountId.equals('') &
                  row.deletedAt.isNull(),
            ))
            .write(InvestmentsCompanion(accountId: Value(accountId)));
        await (update(physicalAssets)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.accountId.equals('') &
                  row.deletedAt.isNull(),
            ))
            .write(PhysicalAssetsCompanion(accountId: Value(accountId)));
      }
      final preference = await preferencesFor(userId);
      await into(userPreferences).insertOnConflictUpdate(
        preference
            .toCompanion(false)
            .copyWith(
              selectedHouseholdAccountId: usageType == 'household'
                  ? Value(accountId)
                  : null,
              selectedPortfolioAccountId: usageType == 'portfolio'
                  ? Value(accountId)
                  : null,
              updatedAt: Value(DateTime.now().toUtc()),
            ),
      );
    });
    _schedulePersist(userId);
  }

  Future<bool> accountCanBeUsed(
    String userId,
    String accountId,
    String usageType,
  ) async {
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(accountId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null ||
        (account.usageType != 'unassigned' && account.usageType != usageType)) {
      return false;
    }
    if (usageType == 'portfolio') {
      return await (select(ledgerEntries)
                ..limit(1)
                ..where(
                  (row) =>
                      row.userId.equals(userId) &
                      row.accountId.equals(accountId) &
                      row.deletedAt.isNull(),
                ))
              .getSingleOrNull() ==
          null;
    }
    return await (select(investments)
                  ..limit(1)
                  ..where(
                    (row) =>
                        row.userId.equals(userId) &
                        row.accountId.equals(accountId) &
                        row.deletedAt.isNull(),
                  ))
                .getSingleOrNull() ==
            null &&
        await (select(physicalAssets)
                  ..limit(1)
                  ..where(
                    (row) =>
                        row.userId.equals(userId) &
                        row.accountId.equals(accountId) &
                        row.deletedAt.isNull(),
                  ))
                .getSingleOrNull() ==
            null;
  }

  Future<void> deleteAccount(String id, String userId) async {
    await (update(
      accounts,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      AccountsCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }

  Stream<List<Investment>> watchInvestments(String userId) =>
      (select(investments)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Stream<List<Investment>> watchAllInvestments(String userId) =>
      (select(investments)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Stream<List<Investment>> watchDeletedInvestments(String userId) =>
      (select(investments)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.quantity.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .watch();

  Future<List<Investment>> deletedInvestmentsFor(String userId) =>
      (select(investments)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.quantity.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .get();

  Stream<List<InvestmentPurchase>> watchInvestmentPurchases(String userId) =>
      (select(investmentPurchases)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.purchaseDate)]))
          .watch();

  Stream<List<PortfolioSale>> watchPortfolioSales(String userId) =>
      (select(portfolioSales)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.desc(row.soldAt)]))
          .watch();

  Stream<List<PortfolioAuditLog>> watchPortfolioAuditLogs(String userId) =>
      (select(portfolioAuditLogs)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.desc(row.occurredAt)]))
          .watch();

  Future<void> saveInvestmentPurchase(
    InvestmentPurchasesCompanion value,
  ) async {
    final stamped = value.copyWith(updatedAt: Value(DateTime.now().toUtc()));
    await into(investmentPurchases).insertOnConflictUpdate(stamped);
    _schedulePersist(value.userId.value);
  }

  Future<void> applyPortfolioPurchaseToCash({
    required String userId,
    required String accountId,
    required double amount,
    required DateTime purchasedAt,
  }) async {
    if (amount < 0) throw ArgumentError('Der Kaufbetrag ist ungültig.');
    final account =
        await (select(accounts)..where(
              (row) => row.id.equals(accountId) & row.userId.equals(userId),
            ))
            .getSingleOrNull();
    if (account == null) throw StateError('Das Portfolio-Konto fehlt.');
    await (update(accounts)..where((row) => row.id.equals(accountId))).write(
      AccountsCompanion(
        balance: Value(account.balance - amount),
        availableBalance: Value(account.availableBalance - amount),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await _writePortfolioAudit(
      userId: userId,
      action: 'purchase_cash',
      entityType: 'account',
      entityId: accountId,
      entityName: account.label,
      details:
          '${purchasedAt.toIso8601String()} · ${amount.toStringAsFixed(2)} ${account.currency}',
    );
    await captureNetWorth(userId);
  }

  Future<void> updateInvestmentPurchase({
    required String userId,
    required String purchaseId,
    required DateTime purchaseDate,
    required double purchasePrice,
    required double quantity,
    required double fees,
  }) async {
    if (purchasePrice < 0 || quantity <= 0 || fees < 0) {
      throw ArgumentError('Kaufkurs, Stückzahl und Gebühren sind ungültig.');
    }
    final purchase =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.id.equals(purchaseId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (purchase == null) throw StateError('Der Kauf wurde nicht gefunden.');
    await transaction(() async {
      await (update(
        investmentPurchases,
      )..where((row) => row.id.equals(purchaseId))).write(
        InvestmentPurchasesCompanion(
          purchaseDate: Value(purchaseDate),
          purchasePrice: Value(purchasePrice),
          quantity: Value(quantity),
          fees: Value(fees),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _recalculateInvestmentFromPurchases(purchase.investmentId, userId);
    });
    await captureNetWorth(userId);
  }

  Future<void> deleteInvestmentPurchase(
    String purchaseId,
    String userId,
  ) async {
    final purchase =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.id.equals(purchaseId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (purchase == null) return;
    final investment =
        await (select(investments)..where(
              (row) =>
                  row.id.equals(purchase.investmentId) &
                  row.userId.equals(userId),
            ))
            .getSingleOrNull();
    await transaction(() async {
      await (update(
        investmentPurchases,
      )..where((row) => row.id.equals(purchaseId))).write(
        InvestmentPurchasesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _writePortfolioAudit(
        userId: userId,
        action: 'deleted',
        entityType: 'purchase',
        entityId: purchaseId,
        entityName: investment?.name ?? 'Kauf',
        details:
            '${purchase.quantity} Stück zu ${purchase.purchasePrice.toStringAsFixed(2)}',
      );
      await _recalculateInvestmentFromPurchases(purchase.investmentId, userId);
    });
    await captureNetWorth(userId);
  }

  Future<void> _recalculateInvestmentFromPurchases(
    String investmentId,
    String userId,
  ) async {
    final rows =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.investmentId.equals(investmentId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final purchasedQuantity = rows.fold<double>(
      0,
      (sum, row) => sum + row.quantity,
    );
    final soldRows =
        await (select(portfolioSales)..where(
              (row) =>
                  row.investmentId.equals(investmentId) &
                  row.userId.equals(userId),
            ))
            .get();
    final soldQuantity = soldRows.fold<double>(
      0,
      (sum, row) => sum + row.quantity,
    );
    if (soldQuantity > purchasedQuantity) {
      throw StateError(
        'Der Kauf kann nicht geändert werden, weil bereits mehr Stück verkauft wurden.',
      );
    }
    final quantity = purchasedQuantity - soldQuantity;
    final purchaseValue = rows.fold<double>(
      0,
      (sum, row) => sum + row.quantity * row.purchasePrice,
    );
    final purchaseFees = rows.fold<double>(0, (sum, row) => sum + row.fees);
    final fees = purchasedQuantity == 0
        ? 0.0
        : purchaseFees * quantity / purchasedQuantity;
    final earliest = rows.isEmpty
        ? null
        : rows.reduce(
            (a, b) => a.purchaseDate.isBefore(b.purchaseDate) ? a : b,
          );
    await (update(investments)..where(
          (row) => row.id.equals(investmentId) & row.userId.equals(userId),
        ))
        .write(
          InvestmentsCompanion(
            quantity: Value(quantity),
            purchasePrice: Value(
              purchasedQuantity == 0 ? 0 : purchaseValue / purchasedQuantity,
            ),
            fees: Value(fees),
            purchaseDate: Value(earliest?.purchaseDate ?? DateTime.now()),
            deletedAt: Value(quantity == 0 ? DateTime.now().toUtc() : null),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<double> _dividendAllowanceUsedThrough({
    required String userId,
    required DateTime through,
    required double allowance,
    required double salesAllowanceUsed,
  }) async {
    final holdings = await (select(
      investments,
    )..where((row) => row.userId.equals(userId))).get();
    final purchases =
        await (select(investmentPurchases)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final sales =
        await (select(portfolioSales)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.soldAt.isSmallerOrEqualValue(through),
            ))
            .get();
    final schedules =
        await (select(dividendSchedules)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final events =
        <
          ({Investment investment, DividendSchedule? schedule, DateTime date})
        >[];
    for (final holding in holdings) {
      final exactMonths = <int>{};
      for (final schedule in schedules.where(
        (row) =>
            row.investmentId == holding.id &&
            (row.paymentYear == through.year ||
                (row.paymentYear == 0 && through.year == DateTime.now().year)),
      )) {
        final date =
            schedule.paymentDate ??
            DateTime(through.year, schedule.paymentMonth);
        if (!date.isAfter(through)) {
          exactMonths.add(schedule.paymentMonth);
          events.add((investment: holding, schedule: schedule, date: date));
        }
      }
      for (final month in dividendPaymentMonths(
        holding.dividendFrequency,
        holding.dividendStartMonth,
      )) {
        final date = DateTime(through.year, month);
        if (!exactMonths.contains(month) &&
            holding.annualDividend > 0 &&
            !date.isAfter(through)) {
          events.add((investment: holding, schedule: null, date: date));
        }
      }
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    var remaining = (allowance - salesAllowanceUsed)
        .clamp(0, double.infinity)
        .toDouble();
    var used = 0.0;
    for (final event in events) {
      final holdingPurchases = purchases
          .where((row) => row.investmentId == event.investment.id)
          .toList();
      final holdingSales = sales
          .where((row) => row.investmentId == event.investment.id)
          .toList();
      final purchased = holdingPurchases.isEmpty
          ? (event.date.isBefore(event.investment.purchaseDate)
                ? 0.0
                : event.investment.quantity +
                      holdingSales.fold<double>(
                        0,
                        (sum, sale) => sum + sale.quantity,
                      ))
          : holdingPurchases
                .where((row) => !row.purchaseDate.isAfter(event.date))
                .fold<double>(0, (sum, row) => sum + row.quantity);
      final sold = holdingSales
          .where((row) => !row.soldAt.isAfter(event.date))
          .fold<double>(0, (sum, row) => sum + row.quantity);
      final quantity = (purchased - sold).clamp(0, double.infinity);
      if (quantity <= 0) continue;
      final schedule = event.schedule;
      final tax = calculateGermanDividendTax(
        grossAmount:
            (schedule?.amountPerShare ?? event.investment.annualDividend) *
            quantity,
        exchangeRate:
            schedule?.exchangeRate ?? event.investment.dividendExchangeRate,
        withholdingTaxRate:
            schedule?.withholdingTaxRate ??
            event.investment.dividendWithholdingTaxRate,
        allowanceRemaining: remaining,
      );
      used += tax.allowanceUsed;
      remaining = tax.allowanceRemaining;
    }
    return used;
  }

  Future<void> sellInvestment({
    required String userId,
    required String investmentId,
    required double quantity,
    required double pricePerUnit,
    required double fees,
    required DateTime soldAt,
  }) async {
    if (quantity <= 0 || pricePerUnit < 0 || fees < 0) {
      throw ArgumentError('Verkaufsdaten sind ungültig.');
    }
    final investment =
        await (select(investments)..where(
              (row) =>
                  row.id.equals(investmentId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (investment == null || quantity > investment.quantity) {
      throw StateError('Die Verkaufsmenge übersteigt den Bestand.');
    }
    final preference = await preferencesFor(userId);
    final yearStart = DateTime(soldAt.year);
    final yearEnd = DateTime(soldAt.year + 1);
    final priorSales =
        await (select(portfolioSales)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.soldAt.isBiggerOrEqualValue(yearStart) &
                  row.soldAt.isSmallerThanValue(yearEnd),
            ))
            .get();
    final dividendAllowanceUsed = await _dividendAllowanceUsedThrough(
      userId: userId,
      through: soldAt,
      allowance: preference.taxAllowance,
      salesAllowanceUsed: priorSales.fold<double>(
        0,
        (sum, row) => sum + row.allowanceUsed,
      ),
    );
    final alreadyUsed =
        priorSales.fold<double>(0, (sum, row) => sum + row.allowanceUsed) +
        dividendAllowanceUsed;
    final grossProceeds = quantity * pricePerUnit;
    final proceedsBeforeTax = (grossProceeds - fees).clamp(0, double.infinity);
    final costBasis =
        quantity * investment.purchasePrice +
        (investment.quantity == 0
            ? 0
            : investment.fees * quantity / investment.quantity);
    final realizedGain = proceedsBeforeTax - costBasis;
    final allowanceAvailable = (preference.taxAllowance - alreadyUsed).clamp(
      0,
      double.infinity,
    ).toDouble();
    final soldInvestments = {
      for (final row in await (select(
        investments,
      )..where((row) => row.userId.equals(userId))).get())
        row.id: row,
    };
    final earlierSales =
        priorSales
            .where(
              (row) =>
                  row.assetKind == 'security' && !row.soldAt.isAfter(soldAt),
            )
            .toList()
          ..sort((a, b) => a.soldAt.compareTo(b.soldAt));
    final tax = saleTax(
      assetType: investment.assetType,
      name: investment.name,
      realizedGain: realizedGain,
      allowanceAvailable: allowanceAvailable,
      priorSales: [
        for (final sale in earlierSales)
          PriorSale(
            assetType: soldInvestments[sale.investmentId]?.assetType ?? '',
            name: soldInvestments[sale.investmentId]?.name ?? sale.assetName,
            realizedGain: sale.realizedGain,
          ),
      ],
    );
    final allowanceUsed = tax.allowanceUsed;
    final taxPaid = tax.taxPaid;
    final proceeds = ((proceedsBeforeTax - taxPaid) * 100).round() / 100;
    final remainingQuantity =
        ((investment.quantity - quantity) * 1000000).round() / 1000000;
    await transaction(() async {
      await into(portfolioSales).insert(
        PortfolioSalesCompanion.insert(
          id: _uuid.v4(),
          userId: userId,
          accountId: investment.accountId,
          investmentId: Value(investment.id),
          assetName: investment.name,
          assetKind: 'security',
          quantity: quantity,
          unit: 'Stück',
          pricePerUnit: pricePerUnit,
          fees: Value(fees),
          proceeds: proceeds,
          costBasis: Value(costBasis),
          realizedGain: Value(realizedGain),
          allowanceUsed: Value(allowanceUsed),
          taxPaid: Value(taxPaid),
          soldAt: soldAt,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await (update(
        investments,
      )..where((row) => row.id.equals(investment.id))).write(
        InvestmentsCompanion(
          quantity: Value(remainingQuantity),
          fees: Value(
            investment.quantity == 0
                ? 0
                : investment.fees * remainingQuantity / investment.quantity,
          ),
          deletedAt: Value(
            remainingQuantity <= 0 ? DateTime.now().toUtc() : null,
          ),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      final cashAccount = await (select(
        accounts,
      )..where((row) => row.id.equals(investment.accountId))).getSingle();
      await (update(accounts)..where(
            (row) =>
                row.id.equals(investment.accountId) & row.userId.equals(userId),
          ))
          .write(
            AccountsCompanion(
              balance: Value(cashAccount.balance + proceeds),
              availableBalance: Value(
                cashAccount.availableBalance + proceeds,
              ),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  Future<void> sellPhysicalAsset({
    required String userId,
    required String assetId,
    required double grams,
    required double pricePerGram,
    required double fees,
    required DateTime soldAt,
    String? destinationAccountId,
  }) async {
    if (grams <= 0 || pricePerGram < 0 || fees < 0) {
      throw ArgumentError('Verkaufsdaten sind ungültig.');
    }
    final asset =
        await (select(physicalAssets)..where(
              (row) =>
                  row.id.equals(assetId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (asset == null || grams > asset.weightGrams) {
      throw StateError('Die Verkaufsmenge übersteigt den Bestand.');
    }
    final proceedsBeforeTax = (grams * pricePerGram - fees).clamp(
      0,
      double.infinity,
    );
    final costBasis = asset.weightGrams == 0
        ? 0.0
        : asset.purchasePrice * grams / asset.weightGrams;
    final realizedGain = proceedsBeforeTax - costBasis;
    final preference = await preferencesFor(userId);
    var allowanceUsed = 0.0;
    var taxPaid = 0.0;
    if (preference.includePhysicalAssetsInTaxAllowance && realizedGain > 0) {
      final yearStart = DateTime(soldAt.year);
      final yearEnd = DateTime(soldAt.year + 1);
      final priorSales =
          await (select(portfolioSales)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.soldAt.isBiggerOrEqualValue(yearStart) &
                    row.soldAt.isSmallerThanValue(yearEnd),
              ))
              .get();
      final dividendAllowanceUsed = await _dividendAllowanceUsedThrough(
        userId: userId,
        through: soldAt,
        allowance: preference.taxAllowance,
        salesAllowanceUsed: priorSales.fold<double>(
          0,
          (sum, row) => sum + row.allowanceUsed,
        ),
      );
      final alreadyUsed =
          priorSales.fold<double>(0, (sum, row) => sum + row.allowanceUsed) +
          dividendAllowanceUsed;
      final available = (preference.taxAllowance - alreadyUsed).clamp(
        0,
        double.infinity,
      );
      allowanceUsed = realizedGain.clamp(0, available).toDouble();
      final taxable = (realizedGain - allowanceUsed).clamp(0, double.infinity);
      final capitalTax = taxable * .25;
      taxPaid = ((capitalTax + capitalTax * .055) * 100).round() / 100;
    }
    final proceeds = ((proceedsBeforeTax - taxPaid) * 100).round() / 100;
    final remainingGrams =
        ((asset.weightGrams - grams) * 1000000).round() / 1000000;
    await transaction(() async {
      await into(portfolioSales).insert(
        PortfolioSalesCompanion.insert(
          id: _uuid.v4(),
          userId: userId,
          accountId: asset.accountId,
          destinationAccountId: Value(destinationAccountId),
          accountCredited: Value(destinationAccountId != null),
          physicalAssetId: Value(asset.id),
          assetName: asset.name,
          assetKind: 'physical',
          quantity: grams,
          unit: 'g',
          pricePerUnit: pricePerGram,
          fees: Value(fees),
          proceeds: proceeds,
          costBasis: Value(costBasis),
          realizedGain: Value(realizedGain),
          allowanceUsed: Value(allowanceUsed),
          taxPaid: Value(taxPaid),
          soldAt: soldAt,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await (update(
        physicalAssets,
      )..where((row) => row.id.equals(asset.id))).write(
        PhysicalAssetsCompanion(
          weightGrams: Value(remainingGrams),
          purchasePrice: Value(
            (asset.purchasePrice - costBasis).clamp(0, double.infinity),
          ),
          currentValue: Value(remainingGrams * asset.currentPricePerGram),
          deletedAt: Value(remainingGrams <= 0 ? DateTime.now().toUtc() : null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      if (destinationAccountId != null) {
        final account =
            await (select(accounts)..where(
                  (row) =>
                      row.id.equals(destinationAccountId) &
                      row.userId.equals(userId) &
                      row.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (account == null) {
          throw StateError('Das Zielkonto ist nicht verfügbar.');
        }
        await (update(
          accounts,
        )..where((row) => row.id.equals(destinationAccountId))).write(
          AccountsCompanion(
            balance: Value(account.balance + proceeds),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });
    await captureNetWorth(userId);
  }

  Future<void> _writePortfolioAudit({
    required String userId,
    required String action,
    required String entityType,
    required String entityId,
    required String entityName,
    String details = '',
  }) => into(portfolioAuditLogs).insert(
    PortfolioAuditLogsCompanion.insert(
      id: _uuid.v4(),
      userId: userId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      displayName: entityName,
      details: Value(details),
      occurredAt: DateTime.now().toUtc(),
    ),
  );

  Future<void> saveInvestment(InvestmentsCompanion value) async {
    final accountId = value.accountId.value;
    final userId = value.userId.value;
    if (accountId.isEmpty ||
        !await accountCanBeUsed(userId, accountId, 'portfolio')) {
      throw StateError(
        'Für Portfolio-Positionen ist ein freies Portfolio-Konto erforderlich.',
      );
    }
    await (update(
          accounts,
        )..where((row) => row.id.equals(accountId) & row.userId.equals(userId)))
        .write(
          AccountsCompanion(
            usageType: const Value('portfolio'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
    await into(investments).insertOnConflictUpdate(value);
    await captureNetWorth(userId);
  }

  Future<void> deleteInvestment(String id, String userId) async {
    final investment =
        await (select(investments)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (investment == null || investment.deletedAt != null) return;
    final refundable = await _cashAppliedPurchaseTotal(id, userId);
    await transaction(() async {
      if (refundable > 0) {
        await _changePortfolioCash(
          userId: userId,
          accountId: investment.accountId,
          delta: refundable,
        );
      }
      await _writePortfolioAudit(
        userId: userId,
        action: 'deleted',
        entityType: 'investment',
        entityId: id,
        entityName: investment.name,
        details:
            '${investment.quantity} Stück · ${refundable.toStringAsFixed(2)} Kontoguthaben freigegeben',
      );
      await (update(
        investments,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        InvestmentsCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    });
    await captureNetWorth(userId);
  }

  Future<void> restoreInvestment(String id, String userId) async {
    final investment =
        await (select(investments)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (investment == null || investment.deletedAt == null) return;
    final purchaseCash = await _cashAppliedPurchaseTotal(id, userId);
    await transaction(() async {
      if (purchaseCash > 0) {
        await _changePortfolioCash(
          userId: userId,
          accountId: investment.accountId,
          delta: -purchaseCash,
        );
      }
      await (update(
        investments,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        InvestmentsCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _writePortfolioAudit(
        userId: userId,
        action: 'restored',
        entityType: 'investment',
        entityId: id,
        entityName: investment.name,
        details:
            '${purchaseCash.toStringAsFixed(2)} Kontoguthaben wieder gebunden',
      );
    });
    await captureNetWorth(userId);
  }

  Future<double> _cashAppliedPurchaseTotal(
    String investmentId,
    String userId,
  ) async {
    final rows =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.investmentId.equals(investmentId) &
                  row.userId.equals(userId) &
                  row.cashApplied.equals(true) &
                  row.deletedAt.isNull(),
            ))
            .get();
    return rows.fold<double>(
      0,
      (sum, row) => sum + row.purchasePrice * row.quantity + row.fees,
    );
  }

  Future<void> _changePortfolioCash({
    required String userId,
    required String accountId,
    required double delta,
  }) async {
    final account =
        await (select(accounts)..where(
              (row) => row.id.equals(accountId) & row.userId.equals(userId),
            ))
            .getSingleOrNull();
    if (account == null) throw StateError('Das Portfolio-Konto fehlt.');
    await (update(accounts)..where((row) => row.id.equals(accountId))).write(
      AccountsCompanion(
        balance: Value(account.balance + delta),
        availableBalance: Value(account.availableBalance + delta),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> updateInvestmentCurrentPrice({
    required String id,
    required String userId,
    required double currentPrice,
  }) async {
    if (currentPrice < 0) {
      throw ArgumentError('Der Kurs darf nicht negativ sein.');
    }
    await (update(
      investments,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      InvestmentsCompanion(
        currentPrice: Value(currentPrice),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }

  Future<void> updateInvestmentDividend({
    required String id,
    required String userId,
    required double dividendPerShare,
  }) async {
    if (dividendPerShare < 0) throw ArgumentError('Ungültige Dividende.');
    await (update(
      investments,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      InvestmentsCompanion(
        annualDividend: Value(dividendPerShare),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<PhysicalAsset>> watchPhysicalAssets(String userId) =>
      (select(physicalAssets)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.category),
              (row) => OrderingTerm.asc(row.name),
            ]))
          .watch();

  Stream<List<PhysicalAsset>> watchAllPhysicalAssets(String userId) =>
      (select(physicalAssets)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([
              (row) => OrderingTerm.asc(row.category),
              (row) => OrderingTerm.asc(row.name),
            ]))
          .watch();

  Stream<List<PhysicalAsset>> watchDeletedPhysicalAssets(String userId) =>
      (select(physicalAssets)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.weightGrams.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .watch();

  Future<List<PhysicalAsset>> deletedPhysicalAssetsFor(String userId) =>
      (select(physicalAssets)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.weightGrams.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .get();

  Future<void> savePhysicalAsset(PhysicalAssetsCompanion value) async {
    final accountId = value.accountId.value;
    final userId = value.userId.value;
    if (accountId.isEmpty ||
        !await accountCanBeUsed(userId, accountId, 'portfolio')) {
      throw StateError(
        'Für physische Werte ist ein freies Portfolio-Konto erforderlich.',
      );
    }
    await (update(
          accounts,
        )..where((row) => row.id.equals(accountId) & row.userId.equals(userId)))
        .write(
          AccountsCompanion(
            usageType: const Value('portfolio'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
    await into(physicalAssets).insertOnConflictUpdate(value);
    await captureNetWorth(userId);
  }

  Future<void> deletePhysicalAsset(String id, String userId) async {
    final asset =
        await (select(physicalAssets)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (asset != null) {
      await _writePortfolioAudit(
        userId: userId,
        action: 'deleted',
        entityType: 'physical',
        entityId: id,
        entityName: asset.name,
        details: '${asset.weightGrams} g',
      );
    }
    await (update(
      physicalAssets,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      PhysicalAssetsCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }

  Future<void> restorePhysicalAsset(String id, String userId) async {
    final asset =
        await (select(physicalAssets)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (asset == null) return;
    await (update(
      physicalAssets,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      PhysicalAssetsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await _writePortfolioAudit(
      userId: userId,
      action: 'restored',
      entityType: 'physical',
      entityId: id,
      entityName: asset.name,
    );
    await captureNetWorth(userId);
  }

  Stream<List<DividendSchedule>> watchDividendSchedules(String userId) =>
      (select(dividendSchedules)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.paymentMonth),
              (row) => OrderingTerm.asc(row.investmentId),
            ]))
          .watch();

  Future<void> saveDividendSchedule(DividendSchedulesCompanion value) async {
    await into(dividendSchedules).insertOnConflictUpdate(value);
    _schedulePersist(value.userId.value);
  }

  Future<void> deleteDividendSchedule(String id, String userId) async {
    await (update(
      dividendSchedules,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      DividendSchedulesCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  Stream<List<LedgerEntry>> watchLedgerEntries(String userId) =>
      (select(ledgerEntries)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.bookingDate)]))
          .watch();

  Stream<List<MasterDataData>> watchMasterData(String userId) =>
      (select(masterData)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.kind),
              (row) => OrderingTerm.asc(row.value),
            ]))
          .watch();

  Stream<List<AppReminder>> watchReminders(String userId) =>
      (select(reminders)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)]))
          .watch();

  Future<void> saveReminder(RemindersCompanion value) async {
    await into(reminders).insertOnConflictUpdate(value);
    _schedulePersist(value.userId.value);
  }

  Future<void> deleteReminder(String id, String userId) async {
    await (update(
      reminders,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      RemindersCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  Future<void> saveMasterDatum(MasterDataCompanion value) async {
    await into(masterData).insert(value, mode: InsertMode.insertOrIgnore);
    _schedulePersist(value.userId.value);
  }

  Future<void> deleteMasterDatum(String id, String userId) async {
    await (update(
      masterData,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      MasterDataCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  Future<void> saveLedgerEntry(LedgerEntriesCompanion value) =>
      saveLedgerEntries([value]);

  Future<void> saveLedgerEntries(
    Iterable<LedgerEntriesCompanion> values,
  ) async {
    final entriesToSave = values.toList();
    await transaction(() async {
      for (final value in entriesToSave) {
        final accountId = value.accountId.present ? value.accountId.value : '';
        if (accountId.isNotEmpty) {
          final userId = value.userId.value;
          if (!await accountCanBeUsed(userId, accountId, 'household')) {
            throw StateError(
              'Das Konto ist bereits einem Portfolio oder anderen Daten zugeordnet.',
            );
          }
          await (update(accounts)..where(
                (row) => row.id.equals(accountId) & row.userId.equals(userId),
              ))
              .write(
                AccountsCompanion(
                  usageType: const Value('household'),
                  updatedAt: Value(DateTime.now().toUtc()),
                ),
              );
          final preference = await preferencesFor(userId);
          if (preference.selectedHouseholdAccountId.isEmpty) {
            await into(userPreferences).insertOnConflictUpdate(
              preference
                  .toCompanion(false)
                  .copyWith(
                    selectedHouseholdAccountId: Value(accountId),
                    updatedAt: Value(DateTime.now().toUtc()),
                  ),
            );
          }
        }
        final old = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(value.id.value))).getSingleOrNull();
        if (old != null) await _applyLedgerToAccount(old, reverse: true);
        await into(ledgerEntries).insertOnConflictUpdate(value);
        final saved = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(value.id.value))).getSingle();
        await _applyLedgerToAccount(saved);
        final linkedCostId = 'ledger:${saved.id}';
        if (saved.vehicleId.isNotEmpty &&
            !saved.isIncome &&
            saved.sourceType != 'vehicle') {
          await into(vehicleCosts).insertOnConflictUpdate(
            VehicleCostsCompanion.insert(
              id: linkedCostId,
              userId: saved.userId,
              vehicleId: saved.vehicleId,
              bookingDate: saved.bookingDate,
              category: saved.category,
              amount: saved.amount,
              notes: Value(
                saved.description.isNotEmpty
                    ? saved.description
                    : saved.merchant,
              ),
              createdAt: old?.createdAt ?? saved.createdAt,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        } else {
          await (update(
            vehicleCosts,
          )..where((row) => row.id.equals(linkedCostId))).write(
            VehicleCostsCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
        }
      }
    });
    for (final userId in entriesToSave.map((e) => e.userId.value).toSet()) {
      await captureNetWorth(userId);
    }
  }

  /// Applies [template] to every entry of a monthly series.
  ///
  /// Transfers and savings keep both legs: entries on the other side of
  /// [edited] (the incoming or outgoing counterpart) only take over amount
  /// and texts and keep their own account, direction and category. Every
  /// entry keeps its own link to its counterpart.
  Future<void> updateLedgerSeries(
    String recurrenceId,
    String userId,
    LedgerEntriesCompanion template, {
    LedgerEntry? edited,
  }) async {
    if (recurrenceId.isEmpty) return;
    final existing =
        await (select(ledgerEntries)..where(
              (row) =>
                  row.recurrenceId.equals(recurrenceId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final now = DateTime.now().toUtc();
    final editedIsIncome =
        edited?.isIncome ??
        (template.isIncome.present ? template.isIncome.value : false);
    final replacements = existing.map((entry) {
      if (_isLinkedLedgerEntry(entry) && entry.isIncome != editedIsIncome) {
        return _counterpartUpdate(entry, template, now, keepDate: true);
      }
      return template.copyWith(
        id: Value(entry.id),
        userId: Value(entry.userId),
        bookingDate: Value(entry.bookingDate),
        budgetMonth: Value(entry.budgetMonth),
        recurrenceId: Value(entry.recurrenceId),
        sourceType: Value(entry.sourceType),
        sourceId: Value(entry.sourceId),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(now),
      );
    }).toList();
    await saveLedgerEntries(replacements);
  }

  /// Saves an edited entry. For transfers and savings the other leg follows
  /// amount, date and texts, so both account balances stay consistent.
  Future<void> saveLedgerEntryWithCounterpart(
    LedgerEntriesCompanion value,
  ) async {
    final sourceType = value.sourceType.present ? value.sourceType.value : '';
    final sourceId = value.sourceId.present ? value.sourceId.value : '';
    if ((sourceType != 'transfer' && sourceType != 'saving') ||
        sourceId.isEmpty) {
      return saveLedgerEntries([value]);
    }
    final counterparts =
        await (select(ledgerEntries)..where(
              (row) =>
                  row.sourceId.equals(sourceId) &
                  row.userId.equals(value.userId.value) &
                  row.id.equals(value.id.value).not() &
                  row.deletedAt.isNull(),
            ))
            .get();
    final now = DateTime.now().toUtc();
    await saveLedgerEntries([
      value,
      for (final counterpart in counterparts)
        _counterpartUpdate(counterpart, value, now, keepDate: false),
    ]);
  }

  bool _isLinkedLedgerEntry(LedgerEntry entry) =>
      (entry.sourceType == 'transfer' || entry.sourceType == 'saving') &&
      entry.sourceId.isNotEmpty;

  LedgerEntriesCompanion _counterpartUpdate(
    LedgerEntry counterpart,
    LedgerEntriesCompanion source,
    DateTime now, {
    required bool keepDate,
  }) {
    final companion = counterpart.toCompanion(false);
    return companion.copyWith(
      amount: source.amount.present ? source.amount : companion.amount,
      bookingDate: !keepDate && source.bookingDate.present
          ? source.bookingDate
          : companion.bookingDate,
      budgetMonth: !keepDate && source.budgetMonth.present
          ? source.budgetMonth
          : companion.budgetMonth,
      merchant: source.merchant.present ? source.merchant : companion.merchant,
      description: source.description.present
          ? source.description
          : companion.description,
      paymentMethod: source.paymentMethod.present
          ? source.paymentMethod
          : companion.paymentMethod,
      // Left out so saveLedgerEntries reverses and re-applies the leg.
      accountApplied: const Value.absent(),
      updatedAt: Value(now),
    );
  }

  Future<void> deleteLedgerEntry(String id, String userId) async {
    await transaction(() async {
      final entry =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.id.equals(id) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (entry == null) return;
      await _applyLedgerToAccount(entry, reverse: true);
      await (update(
        ledgerEntries,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        LedgerEntriesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      final linkedCostIds = [
        'ledger:${entry.id}',
        if (entry.sourceType == 'vehicle' && entry.sourceId.isNotEmpty)
          entry.sourceId,
      ];
      await (update(vehicleCosts)..where(
            (row) => row.id.isIn(linkedCostIds) & row.userId.equals(userId),
          ))
          .write(
            VehicleCostsCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  Future<void> deleteLinkedLedgerEntries(String sourceId, String userId) async {
    if (sourceId.isEmpty) return;
    await transaction(() async {
      final entries =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.sourceId.equals(sourceId) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .get();
      for (final entry in entries) {
        await _applyLedgerToAccount(entry, reverse: true);
      }
      await (update(ledgerEntries)..where(
            (row) =>
                row.sourceId.equals(sourceId) &
                row.userId.equals(userId) &
                row.deletedAt.isNull(),
          ))
          .write(
            LedgerEntriesCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  /// Restores previously deleted ledger entries, e.g. after "Rückgängig".
  ///
  /// The entries are saved as new so their account effect is applied again.
  Future<void> restoreLedgerEntries(Iterable<LedgerEntry> entries) {
    final now = DateTime.now().toUtc();
    return saveLedgerEntries(
      entries.map(
        (entry) => entry
            .toCompanion(false)
            .copyWith(
              deletedAt: const Value(null),
              accountApplied: const Value(false),
              updatedAt: Value(now),
            ),
      ),
    );
  }

  Future<void> deleteLedgerSeries(String recurrenceId, String userId) async {
    await transaction(() async {
      final entries =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.recurrenceId.equals(recurrenceId) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .get();
      for (final entry in entries) {
        await _applyLedgerToAccount(entry, reverse: true);
      }
      await (update(ledgerEntries)..where(
            (row) =>
                row.recurrenceId.equals(recurrenceId) &
                row.userId.equals(userId),
          ))
          .write(
            LedgerEntriesCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  Future<void> _applyLedgerToAccount(
    LedgerEntry entry, {
    bool reverse = false,
  }) async {
    if (entry.accountId.isEmpty || entry.deletedAt != null) return;
    if (reverse && !entry.accountApplied) return;
    if (!reverse && entry.accountApplied) return;
    final now = DateTime.now();
    final bookingDay = ledgerEffectiveDate(
      entry.bookingDate,
      entry.budgetMonth,
    );
    final today = DateTime(now.year, now.month, now.day);
    if (bookingDay.isAfter(today)) return;
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(entry.accountId) &
                  row.userId.equals(entry.userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null) return;
    var delta = entry.isIncome ? entry.amount : -entry.amount;
    if (reverse) delta = -delta;
    await (update(accounts)..where((row) => row.id.equals(account.id))).write(
      AccountsCompanion(
        balance: Value(account.balance + delta),
        availableBalance: Value(account.availableBalance + delta),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await (update(ledgerEntries)..where((row) => row.id.equals(entry.id)))
        .write(LedgerEntriesCompanion(accountApplied: Value(!reverse)));
  }

  Future<bool> _applyDueLedgerEntries(String userId) => transaction(() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final due =
        await (select(ledgerEntries)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNull() &
                  row.accountApplied.equals(false) &
                  row.accountId.isNotValue('') &
                  row.bookingDate.isSmallerThanValue(tomorrow),
            ))
            .get();
    for (final entry in due) {
      await _applyLedgerToAccount(entry);
    }
    return due.isNotEmpty;
  });

  Future<Map<String, Object?>> exportUserData(String userId) async {
    final user = await userById(userId);
    final accountRows = await (select(
      accounts,
    )..where((r) => r.userId.equals(userId))).get();
    final accountHistoryRows = await (select(
      accountBalanceHistories,
    )..where((r) => r.userId.equals(userId))).get();
    final investmentRows = await (select(
      investments,
    )..where((r) => r.userId.equals(userId))).get();
    final physicalAssetRows = await (select(
      physicalAssets,
    )..where((r) => r.userId.equals(userId))).get();
    final purchaseRows = await (select(
      investmentPurchases,
    )..where((r) => r.userId.equals(userId))).get();
    final saleRows = await (select(
      portfolioSales,
    )..where((r) => r.userId.equals(userId))).get();
    final auditRows = await (select(
      portfolioAuditLogs,
    )..where((r) => r.userId.equals(userId))).get();
    final dividendRows = await (select(
      dividendSchedules,
    )..where((r) => r.userId.equals(userId))).get();
    final ledgerRows = await (select(
      ledgerEntries,
    )..where((r) => r.userId.equals(userId))).get();
    final vehicleRows = await (select(
      vehicles,
    )..where((r) => r.userId.equals(userId))).get();
    final costRows = await (select(
      vehicleCosts,
    )..where((r) => r.userId.equals(userId))).get();
    final masterRows = await (select(
      masterData,
    )..where((r) => r.userId.equals(userId))).get();
    final reminderRows = await (select(
      reminders,
    )..where((r) => r.userId.equals(userId))).get();
    final snapshotRows = await (select(
      netWorthSnapshots,
    )..where((r) => r.userId.equals(userId))).get();
    final preferences = await (select(
      userPreferences,
    )..where((r) => r.userId.equals(userId))).getSingleOrNull();
    final stockIds = investmentRows
        .map((row) => row.stockId)
        .whereType<String>()
        .toSet();
    final stockRows = stockIds.isEmpty
        ? const <StockMaster>[]
        : await (select(stockMasters)..where((r) => r.id.isIn(stockIds))).get();
    return {
      'format': 'WealthFlow readonly export',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'user': user == null
          ? null
          : {
              'id': user.id,
              'email': user.email,
              'displayName': user.displayName,
            },
      'accounts': accountRows.map((e) => e.toJson()).toList(),
      'accountBalanceHistories': accountHistoryRows
          .map((e) => e.toJson())
          .toList(),
      'investments': investmentRows.map((e) => e.toJson()).toList(),
      'physicalAssets': physicalAssetRows.map((e) => e.toJson()).toList(),
      'investmentPurchases': purchaseRows.map((e) => e.toJson()).toList(),
      'portfolioSales': saleRows.map((e) => e.toJson()).toList(),
      'portfolioAuditLogs': auditRows.map((e) => e.toJson()).toList(),
      'dividendSchedules': dividendRows.map((e) => e.toJson()).toList(),
      'ledgerEntries': ledgerRows.map((e) => e.toJson()).toList(),
      'vehicles': vehicleRows.map((e) => e.toJson()).toList(),
      'vehicleCosts': costRows.map((e) => e.toJson()).toList(),
      'masterData': masterRows.map((e) => e.toJson()).toList(),
      'reminders': reminderRows.map((e) => e.toJson()).toList(),
      'netWorthSnapshots': snapshotRows.map((e) => e.toJson()).toList(),
      // Catalogue entries the positions refer to, so a restore on a fresh
      // device does not leave investments pointing at missing master data.
      'stockMasters': stockRows.map((e) => e.toJson()).toList(),
      'preferences': preferences?.toJson(),
    };
  }

  /// Merges an exported data file into the account of [userId].
  ///
  /// Rows are always assigned to [userId], so a backup made under another
  /// account (for example before a reinstall) can be restored. Afterwards the
  /// account balances are corrected by every booking, sale and purchase whose
  /// cash effect differs from the version the kept balance was based on.
  Future<void> mergeUserData(String userId, Map<String, dynamic> data) async {
    List<Map<String, dynamic>> rows(String key) =>
        (data[key] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((row) => {...Map<String, dynamic>.from(row), 'userId': userId})
            .toList();

    final stockIdReplacements = <String, String>{};
    for (final json in data['stockMasters'] as List<dynamic>? ?? const []) {
      if (json is! Map) continue;
      final remote = StockMaster.fromJson(Map<String, dynamic>.from(json));
      final existing = await (select(
        stockMasters,
      )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
      if (existing != null) continue;
      final match = await _matchingStockMaster(remote.toCompanion(false));
      if (match != null) {
        stockIdReplacements[remote.id] = match.id;
      } else {
        await into(
          stockMasters,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
    }

    final localAccounts = {
      for (final row in await (select(
        accounts,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final localEntries = {
      for (final row in await (select(
        ledgerEntries,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final localSales = {
      for (final row in await (select(
        portfolioSales,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final localPurchases = {
      for (final row in await (select(
        investmentPurchases,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final remoteEntries = {
      for (final json in rows('ledgerEntries'))
        json['id'] as String: LedgerEntry.fromJson(json),
    };
    final remoteSales = <String, PortfolioSale>{};
    final remotePurchases = <String, InvestmentPurchase>{};
    final balanceFromFile = <String>{};

    await transaction(() async {
      for (final json in rows('accounts')) {
        final remote = Account.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          accounts,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          balanceFromFile.add(remote.id);
          await into(
            accounts,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('accountBalanceHistories')) {
        final remote = AccountBalanceHistory.fromJson(json);
        if (remote.userId != userId) continue;
        await into(
          accountBalanceHistories,
        ).insertOnConflictUpdate(remote.toCompanion(false));
      }
      for (final json in rows('investments')) {
        final stockId = json['stockId'];
        final remote = Investment.fromJson({
          ...json,
          'stockId': stockIdReplacements[stockId] ?? stockId,
        });
        if (remote.userId != userId) continue;
        final local = await (select(
          investments,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            investments,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('physicalAssets')) {
        final remote = PhysicalAsset.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          physicalAssets,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            physicalAssets,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('investmentPurchases')) {
        final remote = InvestmentPurchase.fromJson({
          'cashApplied': false,
          ...json,
        });
        if (remote.userId != userId) continue;
        remotePurchases[remote.id] = remote;
        await into(
          investmentPurchases,
        ).insertOnConflictUpdate(remote.toCompanion(false));
      }
      for (final json in rows('portfolioSales')) {
        final remote = PortfolioSale.fromJson({
          'accountCredited': true,
          'sourceCurrency': 'EUR',
          'exchangeRate': 1,
          ...json,
        });
        if (remote.userId != userId) continue;
        remoteSales[remote.id] = remote;
        await into(
          portfolioSales,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
      for (final json in rows('portfolioAuditLogs')) {
        final remote = PortfolioAuditLog.fromJson(json);
        if (remote.userId != userId) continue;
        await into(
          portfolioAuditLogs,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
      for (final json in rows('dividendSchedules')) {
        final remote = DividendSchedule.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          dividendSchedules,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            dividendSchedules,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('ledgerEntries')) {
        final remote = LedgerEntry.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            ledgerEntries,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('masterData')) {
        final remote = MasterDataData.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          masterData,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        final remoteChanged = remote.updatedAt ?? remote.createdAt;
        final localChanged = local?.updatedAt ?? local?.createdAt;
        if (local == null || remoteChanged.isAfter(localChanged!)) {
          await into(
            masterData,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('reminders')) {
        final remote = AppReminder.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          reminders,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            reminders,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('vehicles')) {
        final remote = Vehicle.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          vehicles,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            vehicles,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('vehicleCosts')) {
        final remote = VehicleCost.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          vehicleCosts,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            vehicleCosts,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('netWorthSnapshots')) {
        final remote = NetWorthSnapshot.fromJson({
          ...json,
          'vehicleValue': json['vehicleValue'] ?? 0,
        });
        if (remote.userId != userId) continue;
        await into(
          netWorthSnapshots,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
      await _correctBalancesAfterMerge(
        userId: userId,
        balanceFromFile: balanceFromFile,
        localAccounts: localAccounts,
        localEntries: localEntries,
        remoteEntries: remoteEntries,
        localSales: localSales,
        remoteSales: remoteSales,
        localPurchases: localPurchases,
        remotePurchases: remotePurchases,
      );
    });
    await _applyDueLedgerEntries(userId);
    await captureNetWorth(userId);
  }

  /// Each kept balance already contains the cash effects of the side it came
  /// from (this device or the file). The difference to the merged rows is
  /// booked on top, so no booking is lost or counted twice.
  Future<void> _correctBalancesAfterMerge({
    required String userId,
    required Set<String> balanceFromFile,
    required Map<String, Account> localAccounts,
    required Map<String, LedgerEntry> localEntries,
    required Map<String, LedgerEntry> remoteEntries,
    required Map<String, PortfolioSale> localSales,
    required Map<String, PortfolioSale> remoteSales,
    required Map<String, InvestmentPurchase> localPurchases,
    required Map<String, InvestmentPurchase> remotePurchases,
  }) async {
    final mergedAccounts = await (select(
      accounts,
    )..where((r) => r.userId.equals(userId))).get();
    final mergedEntries = {
      for (final row in await (select(
        ledgerEntries,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final mergedSales = {
      for (final row in await (select(
        portfolioSales,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final mergedPurchases = {
      for (final row in await (select(
        investmentPurchases,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final investmentAccounts = {
      for (final row in await (select(
        investments,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row.accountId,
    };

    double ledgerEffect(LedgerEntry? entry, String accountId) =>
        entry == null ||
            entry.accountId != accountId ||
            !entry.accountApplied ||
            entry.deletedAt != null
        ? 0
        : entry.isIncome
        ? entry.amount
        : -entry.amount;
    double saleEffect(PortfolioSale? sale, String accountId) {
      if (sale == null) return 0;
      final credited =
          sale.destinationAccountId ??
          (sale.accountCredited ? sale.accountId : null);
      return credited == accountId ? sale.proceeds : 0;
    }

    double purchaseEffect(InvestmentPurchase? purchase, String accountId) =>
        purchase == null ||
            !purchase.cashApplied ||
            purchase.deletedAt != null ||
            investmentAccounts[purchase.investmentId] != accountId
        ? 0
        : -(purchase.purchasePrice * purchase.quantity + purchase.fees);

    for (final account in mergedAccounts) {
      final fromFile = balanceFromFile.contains(account.id);
      // A balance that existed on neither side has nothing to correct.
      if (!fromFile && !localAccounts.containsKey(account.id)) continue;
      final keptEntries = fromFile ? remoteEntries : localEntries;
      final keptSales = fromFile ? remoteSales : localSales;
      final keptPurchases = fromFile ? remotePurchases : localPurchases;
      var ledgerDelta = 0.0;
      for (final id in {...mergedEntries.keys, ...keptEntries.keys}) {
        ledgerDelta +=
            ledgerEffect(mergedEntries[id], account.id) -
            ledgerEffect(keptEntries[id], account.id);
      }
      var cashDelta = 0.0;
      for (final id in {...mergedSales.keys, ...keptSales.keys}) {
        cashDelta +=
            saleEffect(mergedSales[id], account.id) -
            saleEffect(keptSales[id], account.id);
      }
      for (final id in {...mergedPurchases.keys, ...keptPurchases.keys}) {
        cashDelta +=
            purchaseEffect(mergedPurchases[id], account.id) -
            purchaseEffect(keptPurchases[id], account.id);
      }
      if (ledgerDelta.abs() < 0.000001 && cashDelta.abs() < 0.000001) {
        continue;
      }
      await (update(accounts)..where((row) => row.id.equals(account.id))).write(
        AccountsCompanion(
          balance: Value(account.balance + ledgerDelta + cashDelta),
          availableBalance: Value(
            account.availableBalance + ledgerDelta + cashDelta,
          ),
        ),
      );
    }
  }

  Stream<List<NetWorthSnapshot>> watchNetWorthSnapshots(String userId) =>
      (select(netWorthSnapshots)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.asc(row.capturedAt)]))
          .watch();

  Future<void> captureNetWorth(String userId) async {
    final accountRows =
        await (select(accounts)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final investmentRows =
        await (select(investments)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final physicalRows =
        await (select(physicalAssets)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final vehicleRows =
        await (select(vehicles)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final converter = CurrencyConverter.fromRates(
      (await preferencesFor(userId)).currency,
      await select(countryTaxRates).get(),
    );
    final accountBalance = accountRows.fold<double>(
      0,
      (sum, row) => sum + converter.toBase(row.balance, row.currency),
    );
    final portfolioValue =
        investmentRows.fold<double>(
          0,
          (sum, row) => sum + row.quantity * row.currentPrice,
        ) +
        physicalRows.fold<double>(
          0,
          (sum, row) => sum + row.weightGrams * row.currentPricePerGram,
        );
    final vehicleValue = vehicleRows.fold<double>(
      0,
      (sum, row) => sum + row.currentValue,
    );
    final last =
        await (select(netWorthSnapshots)
              ..where((row) => row.userId.equals(userId))
              ..orderBy([(row) => OrderingTerm.desc(row.capturedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (last != null &&
        last.accountBalance == accountBalance &&
        last.portfolioValue == portfolioValue &&
        last.vehicleValue == vehicleValue) {
      _schedulePersist(userId);
      return;
    }
    await into(netWorthSnapshots).insert(
      NetWorthSnapshotsCompanion.insert(
        id: _uuid.v4(),
        userId: userId,
        capturedAt: DateTime.now().toUtc(),
        accountBalance: accountBalance,
        portfolioValue: portfolioValue,
        totalNetWorth: accountBalance + portfolioValue,
        vehicleValue: Value(vehicleValue),
      ),
    );
    _schedulePersist(userId);
  }

  Future<bool> persistUserFile(String userId) async {
    final preference = await (select(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).getSingleOrNull();
    final path = preference?.dataFilePath ?? '';
    final key = _dataFileKeys[userId];
    if (path.isEmpty || key == null) return false;
    try {
      final data = await exportUserData(userId);
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final encrypted = await DataCipher.encrypt(
        json,
        key,
        backupKey: _backupKeys[userId],
      );
      final written = await writeDataFile(encrypted, path);
      _setBackupStatus(
        userId,
        written
            ? BackupStatus.success(DateTime.now())
            : BackupStatus.failure('Der Speicherort ist nicht beschreibbar.'),
      );
      return written;
    } catch (error, stackTrace) {
      // Local database writes must never fail just because an external backup
      // location is temporarily unavailable, but the user has to learn that
      // the data file is no longer up to date.
      _setBackupStatus(
        userId,
        const BackupStatus.failure(
          'Die Datendatei konnte nicht geschrieben werden.',
        ),
      );
      await logError(
        userId: userId,
        source: 'Datendatei',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void _setBackupStatus(String userId, BackupStatus status) {
    _backupStatus[userId] = status;
    _backupStatusChanges.add(userId);
  }

  Future<void> seedDefaultMasterData(String userId) async {
    const defaults = <String, List<String>>{
      'category': [
        'Einkaufen',
        'Wohnen',
        'Auto',
        'Motorrad',
        'Tanken',
        'Laden',
        'Streaming',
        'Versicherungen',
        'Freizeit',
        'Urlaub',
        'Gesundheit',
        'Gehalt',
        'Dividende',
        'Sonstiges',
      ],
      'paymentMethod': ['Lastschrift', 'Überweisung', 'Karte', 'Bar'],
      'country': [
        'Deutschland',
        'Österreich',
        'Schweiz',
        'Frankreich',
        'Niederlande',
        'Vereinigtes Königreich',
        'USA',
        'Kanada',
        'Japan',
        'China',
        'Australien',
      ],
      'sector': [
        'Technologie',
        'Finanzen',
        'Gesundheit',
        'Industrie',
        'Basiskonsumgüter',
        'Nicht-Basiskonsumgüter',
        'Energie',
        'Versorger',
        'Immobilien',
        'Kommunikation',
      ],
    };
    final now = DateTime.now().toUtc();
    await batch((batch) {
      for (final kind in defaults.entries) {
        for (final value in kind.value) {
          batch.insert(
            masterData,
            MasterDataCompanion.insert(
              id: _uuid.v5(Namespace.url.value, '$userId:${kind.key}:$value'),
              userId: userId,
              kind: kind.key,
              value: value,
              createdAt: now,
              updatedAt: Value(now),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
  }

  Stream<List<Vehicle>> watchVehicles(String userId) =>
      (select(vehicles)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.make)]))
          .watch();

  Future<void> saveVehicle(VehiclesCompanion value) async {
    await into(vehicles).insertOnConflictUpdate(value);
    await captureNetWorth(value.userId.value);
  }

  Future<void> deleteVehicle(String id, String userId) async {
    final now = DateTime.now().toUtc();
    await transaction(() async {
      final linkedEntries =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.vehicleId.equals(id) &
                    row.sourceType.equals('vehicle') &
                    row.deletedAt.isNull(),
              ))
              .get();
      for (final entry in linkedEntries) {
        await _applyLedgerToAccount(entry, reverse: true);
      }
      await (update(
        vehicles,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        VehiclesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (update(vehicleCosts)..where(
            (row) => row.vehicleId.equals(id) & row.userId.equals(userId),
          ))
          .write(
            VehicleCostsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
      await (update(ledgerEntries)..where(
            (row) =>
                row.userId.equals(userId) &
                row.vehicleId.equals(id) &
                row.sourceType.equals('vehicle'),
          ))
          .write(
            LedgerEntriesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  Stream<List<VehicleCost>> watchVehicleCosts(String userId) =>
      (select(vehicleCosts)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.bookingDate)]))
          .watch();

  Future<void> saveVehicleCost(VehicleCostsCompanion value) async {
    await into(vehicleCosts).insertOnConflictUpdate(value);
    _schedulePersist(value.userId.value);
  }

  Future<void> saveVehicleCostWithLedger(
    VehicleCostsCompanion cost,
    LedgerEntriesCompanion ledger,
  ) async {
    final preference = await preferencesFor(cost.userId.value);
    final accountId =
        ledger.accountId.present && ledger.accountId.value.isNotEmpty
        ? ledger.accountId.value
        : preference.selectedHouseholdAccountId;
    if (accountId.isEmpty ||
        !await accountCanBeUsed(cost.userId.value, accountId, 'household')) {
      throw StateError(
        'Vor dem Erfassen von Fahrzeugkosten muss ein Haushaltskonto gewählt werden.',
      );
    }
    // When an existing cost is edited, its booking is updated in place so
    // the old amount is taken back from the account first.
    final existingLedger = await vehicleCostLedgerEntry(
      cost.userId.value,
      cost.id.value,
    );
    await into(vehicleCosts).insertOnConflictUpdate(cost);
    await saveLedgerEntry(
      ledger.copyWith(
        id: existingLedger == null ? null : Value(existingLedger.id),
        createdAt: existingLedger == null
            ? null
            : Value(existingLedger.createdAt),
        accountId: Value(accountId),
      ),
    );
  }

  Future<LedgerEntry?> vehicleCostLedgerEntry(String userId, String costId) =>
      (select(ledgerEntries)
            ..limit(1)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.sourceType.equals('vehicle') &
                  row.sourceId.equals(costId) &
                  row.deletedAt.isNull(),
            ))
          .getSingleOrNull();

  /// Deletes a vehicle cost together with its household booking and gives
  /// the amount back to the account.
  Future<void> deleteVehicleCost(String costId, String userId) async {
    if (costId.startsWith('ledger:')) {
      // Created in the household book: the booking owns the cost.
      final entryId = costId.substring('ledger:'.length);
      await deleteLedgerEntry(entryId, userId);
      final now = DateTime.now().toUtc();
      await (update(vehicleCosts)
            ..where((row) => row.id.equals(costId) & row.userId.equals(userId)))
          .write(
            VehicleCostsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
      _schedulePersist(userId);
      return;
    }
    final entry = await vehicleCostLedgerEntry(userId, costId);
    if (entry != null) {
      await deleteLedgerEntry(entry.id, userId);
    } else {
      final now = DateTime.now().toUtc();
      await (update(vehicleCosts)
            ..where((row) => row.id.equals(costId) & row.userId.equals(userId)))
          .write(
            VehicleCostsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
    }
    _schedulePersist(userId);
  }

  Stream<UserPreference?> watchPreferences(String userId) => (select(
    userPreferences,
  )..where((row) => row.userId.equals(userId))).watchSingleOrNull();

  Future<UserPreference> preferencesFor(String userId) async {
    final current = await (select(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).getSingleOrNull();
    if (current != null) return current;
    final now = DateTime.now().toUtc();
    await into(
      userPreferences,
    ).insert(UserPreferencesCompanion.insert(userId: userId, updatedAt: now));
    return (select(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).getSingle();
  }

  Future<void> savePreferences(UserPreferencesCompanion value) async {
    if (value.taxAllowance.present) {
      final maximum = (await appConfiguration()).maximumTaxAllowance;
      if (value.taxAllowance.value < 0 || value.taxAllowance.value > maximum) {
        throw StateError(
          'Der Freistellungsauftrag darf höchstens ${maximum.toStringAsFixed(2)} € betragen.',
        );
      }
    }
    await into(userPreferences).insertOnConflictUpdate(value);
    _schedulePersist(value.userId.value);
  }
}

/// Outcome of the most recent data file write in this session.
final class BackupStatus {
  const BackupStatus.success(DateTime this.writtenAt) : error = null;
  const BackupStatus.failure(String this.error) : writtenAt = null;

  final DateTime? writtenAt;
  final String? error;

  bool get succeeded => error == null;
}

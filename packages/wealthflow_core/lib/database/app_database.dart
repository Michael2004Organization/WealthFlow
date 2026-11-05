import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../security/data_cipher.dart';
import '../finance/budget_period.dart';
import '../finance/currencies.dart';
import '../finance/currency_conversion.dart';
import '../finance/dividend_math.dart';
import '../finance/portfolio_master_data.dart';
import '../finance/sale_tax.dart';

part 'app_database.g.dart';
part 'queries/admin.dart';
part 'queries/accounts.dart';
part 'queries/portfolio.dart';
part 'queries/household.dart';
part 'queries/data_transfer.dart';
part 'queries/preferences.dart';

extension InvestmentPurchaseCash on InvestmentPurchase {
  /// Amount taken from the cash account, in the account's currency.
  double get cashAmount => (purchasePrice * quantity + fees) * exchangeRate;
}

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

  /// Units of the cash account's currency for one unit of the instrument
  /// currency at the time of the purchase.
  RealColumn get exchangeRate => real().withDefault(const Constant(1))();
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
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
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

/// Writes [content] to the data file at [path]; returns false when the
/// location is not writable.
typedef DataFileWriter = Future<bool> Function(String content, String path);

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

  /// Opens the database on [executor]. The app passes its platform
  /// connection, the server its own SQLite file.
  ///
  /// [writeDataFile] stores the encrypted data file at a path; without it
  /// the data file is reported as not writable.
  AppDatabase(super.executor, {this.writeDataFile});

  AppDatabase.forTesting(super.executor, {this.writeDataFile});

  final DataFileWriter? writeDataFile;

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

  /// The password-derived key, sent to the own home server so it can write
  /// a data file that opens on every device.
  BackupKey? backupKeyFor(String userId) => _backupKeys[userId];

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
  int get schemaVersion => 21;

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
        // Market data caches referenced stock_masters and were never filled.
        await customStatement('DROP TABLE IF EXISTS stock_prices');
        await customStatement('DROP TABLE IF EXISTS stock_dividends');
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
      if (from < 20) {
        final purchaseColumns = await customSelect(
          "PRAGMA table_info('investment_purchases')",
        ).get();
        if (purchaseColumns.isNotEmpty &&
            !purchaseColumns.any(
              (row) => row.data['name'] == 'exchange_rate',
            )) {
          await migrator.addColumn(
            investmentPurchases,
            investmentPurchases.exchangeRate,
          );
        }
      }
      if (from < 21) {
        // Unused market-data caches and the API lock of exchange rates: no
        // provider was ever connected.
        for (final table in const [
          'stock_prices',
          'stock_dividends',
          'market_data_refreshes',
          'api_request_days',
        ]) {
          await customStatement('DROP TABLE IF EXISTS $table');
        }
        final rateColumns = await customSelect(
          "PRAGMA table_info('country_tax_rates')",
        ).get();
        if (rateColumns.any(
          (row) => row.data['name'] == 'allow_manual_exchange_rate',
        )) {
          await customStatement(
            'ALTER TABLE country_tax_rates DROP COLUMN allow_manual_exchange_rate',
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

  /// Purchases of a position still held after [soldQuantity] pieces were
  /// sold, oldest first (first in, first out).
  static List<({InvestmentPurchase purchase, double quantity})> remainingLots(
    List<InvestmentPurchase> purchases,
    double soldQuantity,
  ) {
    final sorted = [...purchases]
      ..sort((a, b) {
        final byDate = a.purchaseDate.compareTo(b.purchaseDate);
        return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
      });
    var toSkip = soldQuantity;
    final lots = <({InvestmentPurchase purchase, double quantity})>[];
    for (final purchase in sorted) {
      var left = purchase.quantity;
      if (toSkip > 0) {
        final used = toSkip < left ? toSkip : left;
        left -= used;
        toSkip -= used;
      }
      if (left > 1e-9) lots.add((purchase: purchase, quantity: left));
    }
    return lots;
  }

  static double _roundQuantity(double value) =>
      (value * 100000000).round() / 100000000;

  /// Keys of [exportUserData] that describe the moment or the device rather
  /// than the data itself.
  static const volatileExportKeys = {
    'format',
    'exportedAt',
    'user',
    'preferences',
  };
}

/// Outcome of the most recent data file write in this session.
final class BackupStatus {
  const BackupStatus.success(DateTime this.writtenAt) : error = null;
  const BackupStatus.failure(String this.error) : writtenAt = null;

  final DateTime? writtenAt;
  final String? error;

  bool get succeeded => error == null;
}

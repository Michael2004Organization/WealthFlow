import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../storage/data_export.dart';
import '../security/data_cipher.dart';
import '../finance/budget_period.dart';

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
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get stockId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get symbol => text().withDefault(const Constant(''))();
  TextColumn get isin => text().withDefault(const Constant(''))();
  TextColumn get wkn => text().withDefault(const Constant(''))();
  TextColumn get assetType => text()();
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
  DateTimeColumn get createdAt => dateTime()();

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
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Shared, user-independent stock catalogue. Portfolio rows only reference
/// these records; this prevents duplicate quote requests per user.
class StockMasters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get symbol => text().unique()();
  TextColumn get isin => text().withDefault(const Constant(''))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get country => text().withDefault(const Constant(''))();
  TextColumn get exchange => text().withDefault(const Constant(''))();
  TextColumn get sector => text().withDefault(const Constant(''))();
  TextColumn get companyData => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

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

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Users,
    Accounts,
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
  ],
)
final class AppDatabase extends _$AppDatabase {
  static const _uuid = Uuid();
  final Map<String, List<int>> _dataFileKeys = {};
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

  void clearDataFileKey(String userId) => _dataFileKeys.remove(userId);

  Future<Map<String, dynamic>> decodeUserDataFile(
    String userId,
    String content,
  ) async {
    final key = _dataFileKeys[userId];
    final clear = key == null
        ? content
        : await DataCipher.decrypt(content, key);
    final decoded = jsonDecode(clear);
    if (decoded is! Map) throw const FormatException('Ungültige Datendatei');
    return Map<String, dynamic>.from(decoded);
  }

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
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
    },
  );

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

  Future<void> saveStockMaster(
    String actorUserId,
    StockMastersCompanion value,
  ) async {
    await _requireAdmin(actorUserId);
    await into(stockMasters).insertOnConflictUpdate(value);
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

  Future<StockPrice?> stockPrice(String stockId) => (select(
    stockPrices,
  )..where((row) => row.stockId.equals(stockId))).getSingleOrNull();

  Future<void> saveStockPrice(StockPricesCompanion value) =>
      into(stockPrices).insertOnConflictUpdate(value);

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

  Stream<List<Account>> watchAccounts(String userId) async* {
    if (await _applyDueLedgerEntries(userId)) {
      await captureNetWorth(userId);
    }
    yield* (select(accounts)
          ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.label)]))
        .watch();
  }

  Future<void> saveAccount(AccountsCompanion value) async {
    await into(accounts).insertOnConflictUpdate(value);
    await captureNetWorth(value.userId.value);
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

  Stream<List<InvestmentPurchase>> watchInvestmentPurchases(String userId) =>
      (select(investmentPurchases)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.desc(row.purchaseDate)]))
          .watch();

  Future<void> saveInvestmentPurchase(
    InvestmentPurchasesCompanion value,
  ) async {
    await into(investmentPurchases).insertOnConflictUpdate(value);
    await persistUserFile(value.userId.value);
  }

  Future<void> saveInvestment(InvestmentsCompanion value) async {
    await into(investments).insertOnConflictUpdate(value);
    await captureNetWorth(value.userId.value);
  }

  Future<void> deleteInvestment(String id, String userId) async {
    await (update(
      investments,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      InvestmentsCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
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
    await persistUserFile(value.userId.value);
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
    await persistUserFile(userId);
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
    await persistUserFile(value.userId.value);
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
    await persistUserFile(userId);
  }

  Future<void> saveMasterDatum(MasterDataCompanion value) async {
    await into(masterData).insert(value, mode: InsertMode.insertOrIgnore);
    await persistUserFile(value.userId.value);
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
    await persistUserFile(userId);
  }

  Future<void> saveLedgerEntry(LedgerEntriesCompanion value) =>
      saveLedgerEntries([value]);

  Future<void> saveLedgerEntries(
    Iterable<LedgerEntriesCompanion> values,
  ) async {
    final entriesToSave = values.toList();
    await transaction(() async {
      for (final value in entriesToSave) {
        final old = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(value.id.value))).getSingleOrNull();
        if (old != null) await _applyLedgerToAccount(old, reverse: true);
        await into(ledgerEntries).insertOnConflictUpdate(value);
        final saved = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(value.id.value))).getSingle();
        await _applyLedgerToAccount(saved);
      }
    });
    for (final userId in entriesToSave.map((e) => e.userId.value).toSet()) {
      await captureNetWorth(userId);
    }
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
    final investmentRows = await (select(
      investments,
    )..where((r) => r.userId.equals(userId))).get();
    final purchaseRows = await (select(
      investmentPurchases,
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
      'investments': investmentRows.map((e) => e.toJson()).toList(),
      'investmentPurchases': purchaseRows.map((e) => e.toJson()).toList(),
      'dividendSchedules': dividendRows.map((e) => e.toJson()).toList(),
      'ledgerEntries': ledgerRows.map((e) => e.toJson()).toList(),
      'vehicles': vehicleRows.map((e) => e.toJson()).toList(),
      'vehicleCosts': costRows.map((e) => e.toJson()).toList(),
      'masterData': masterRows.map((e) => e.toJson()).toList(),
      'reminders': reminderRows.map((e) => e.toJson()).toList(),
      'netWorthSnapshots': snapshotRows.map((e) => e.toJson()).toList(),
      'preferences': preferences?.toJson(),
    };
  }

  Future<void> mergeUserData(String userId, Map<String, dynamic> data) async {
    List<Map<String, dynamic>> rows(String key) =>
        (data[key] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();

    await transaction(() async {
      for (final json in rows('accounts')) {
        final remote = Account.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          accounts,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            accounts,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('investments')) {
        final remote = Investment.fromJson(json);
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
      for (final json in rows('investmentPurchases')) {
        final remote = InvestmentPurchase.fromJson(json);
        if (remote.userId != userId) continue;
        await into(
          investmentPurchases,
        ).insertOnConflictUpdate(remote.toCompanion(false));
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
        final remote = NetWorthSnapshot.fromJson(json);
        if (remote.userId != userId) continue;
        await into(
          netWorthSnapshots,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
    });
    await _applyDueLedgerEntries(userId);
    await captureNetWorth(userId);
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
    final accountBalance = accountRows.fold<double>(
      0,
      (sum, row) => sum + row.balance,
    );
    final portfolioValue = investmentRows.fold<double>(
      0,
      (sum, row) => sum + row.quantity * row.currentPrice,
    );
    final last =
        await (select(netWorthSnapshots)
              ..where((row) => row.userId.equals(userId))
              ..orderBy([(row) => OrderingTerm.desc(row.capturedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (last != null &&
        last.accountBalance == accountBalance &&
        last.portfolioValue == portfolioValue) {
      await persistUserFile(userId);
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
      ),
    );
    await persistUserFile(userId);
  }

  Future<bool> persistUserFile(String userId) async {
    try {
      final preference = await (select(
        userPreferences,
      )..where((row) => row.userId.equals(userId))).getSingleOrNull();
      final path = preference?.dataFilePath ?? '';
      if (path.isEmpty) return false;
      final data = await exportUserData(userId);
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final key = _dataFileKeys[userId];
      if (key == null) return false;
      final encrypted = await DataCipher.encrypt(json, key);
      return writeDataFile(encrypted, path);
    } catch (_) {
      // Local database writes must never fail just because an external backup
      // location is temporarily unavailable.
      return false;
    }
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
              id: _uuid.v5(
                Namespace.url.value,
                '$userId:' + kind.key + ':$value',
              ),
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
    await persistUserFile(value.userId.value);
  }

  Future<void> deleteVehicle(String id, String userId) async {
    final now = DateTime.now().toUtc();
    await transaction(() async {
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
    await persistUserFile(userId);
  }

  Stream<List<VehicleCost>> watchVehicleCosts(String userId) =>
      (select(vehicleCosts)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.bookingDate)]))
          .watch();

  Future<void> saveVehicleCost(VehicleCostsCompanion value) async {
    await into(vehicleCosts).insertOnConflictUpdate(value);
    await persistUserFile(value.userId.value);
  }

  Future<void> saveVehicleCostWithLedger(
    VehicleCostsCompanion cost,
    LedgerEntriesCompanion ledger,
  ) async {
    await into(vehicleCosts).insertOnConflictUpdate(cost);
    await saveLedgerEntry(ledger);
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
    await into(userPreferences).insertOnConflictUpdate(value);
    await persistUserFile(value.userId.value);
  }
}

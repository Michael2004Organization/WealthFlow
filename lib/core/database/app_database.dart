import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  TextColumn get profileImagePath => text().nullable()();
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
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LedgerEntry')
class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get bookingDate => dateTime()();
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

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {userId, kind, value},
  ];
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
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

@DriftDatabase(
  tables: [
    Users,
    Accounts,
    Investments,
    LedgerEntries,
    MasterData,
    Vehicles,
    VehicleCosts,
    UserPreferences,
  ],
)
final class AppDatabase extends _$AppDatabase {
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

  @override
  int get schemaVersion => 4;

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
    },
  );

  Future<User?> userByEmail(String email) => (select(
    users,
  )..where((row) => row.email.equals(email.toLowerCase()))).getSingleOrNull();

  Future<User?> userById(String id) =>
      (select(users)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<void> createUser(UsersCompanion user) => into(users).insert(user);

  Future<void> updateUserPassword(String userId, String hash, String salt) =>
      (update(users)..where((row) => row.id.equals(userId))).write(
        UsersCompanion(
          passwordHash: Value(hash),
          passwordSalt: Value(salt),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Stream<List<Account>> watchAccounts(String userId) async* {
    await _applyDueLedgerEntries(userId);
    yield* (select(accounts)
          ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.label)]))
        .watch();
  }

  Future<void> saveAccount(AccountsCompanion value) =>
      into(accounts).insertOnConflictUpdate(value);

  Future<void> deleteAccount(String id, String userId) =>
      (update(
        accounts,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        AccountsCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Stream<List<Investment>> watchInvestments(String userId) =>
      (select(investments)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Future<void> saveInvestment(InvestmentsCompanion value) =>
      into(investments).insertOnConflictUpdate(value);

  Future<void> deleteInvestment(String id, String userId) =>
      (update(
        investments,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        InvestmentsCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Stream<List<LedgerEntry>> watchLedgerEntries(String userId) =>
      (select(ledgerEntries)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.bookingDate)]))
          .watch();

  Stream<List<MasterDataData>> watchMasterData(String userId) =>
      (select(masterData)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([
              (row) => OrderingTerm.asc(row.kind),
              (row) => OrderingTerm.asc(row.value),
            ]))
          .watch();

  Future<void> saveMasterDatum(MasterDataCompanion value) =>
      into(masterData).insert(value, mode: InsertMode.insertOrIgnore);

  Future<void> deleteMasterDatum(String id, String userId) => (delete(
    masterData,
  )..where((row) => row.id.equals(id) & row.userId.equals(userId))).go();

  Future<void> saveLedgerEntry(LedgerEntriesCompanion value) =>
      saveLedgerEntries([value]);

  Future<void> saveLedgerEntries(Iterable<LedgerEntriesCompanion> values) =>
      transaction(() async {
        for (final value in values) {
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

  Future<void> deleteLedgerEntry(String id, String userId) =>
      transaction(() async {
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

  Future<void> deleteLedgerSeries(String recurrenceId, String userId) =>
      transaction(() async {
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

  Future<void> _applyLedgerToAccount(
    LedgerEntry entry, {
    bool reverse = false,
  }) async {
    if (entry.accountId.isEmpty || entry.deletedAt != null) return;
    if (reverse && !entry.accountApplied) return;
    if (!reverse && entry.accountApplied) return;
    final now = DateTime.now();
    final bookingDay = DateTime(
      entry.bookingDate.year,
      entry.bookingDate.month,
      entry.bookingDate.day,
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

  Future<void> _applyDueLedgerEntries(String userId) => transaction(() async {
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
  });

  Future<Map<String, Object?>> exportUserData(String userId) async {
    final user = await userById(userId);
    final accountRows = await (select(
      accounts,
    )..where((r) => r.userId.equals(userId))).get();
    final investmentRows = await (select(
      investments,
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
      'ledgerEntries': ledgerRows.map((e) => e.toJson()).toList(),
      'vehicles': vehicleRows.map((e) => e.toJson()).toList(),
      'vehicleCosts': costRows.map((e) => e.toJson()).toList(),
      'masterData': masterRows.map((e) => e.toJson()).toList(),
    };
  }

  Stream<List<Vehicle>> watchVehicles(String userId) =>
      (select(vehicles)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.make)]))
          .watch();

  Future<void> saveVehicle(VehiclesCompanion value) =>
      into(vehicles).insertOnConflictUpdate(value);

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
  }

  Stream<List<VehicleCost>> watchVehicleCosts(String userId) =>
      (select(vehicleCosts)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.bookingDate)]))
          .watch();

  Future<void> saveVehicleCost(VehicleCostsCompanion value) =>
      into(vehicleCosts).insertOnConflictUpdate(value);

  Future<void> saveVehicleCostWithLedger(
    VehicleCostsCompanion cost,
    LedgerEntriesCompanion ledger,
  ) => transaction(() async {
    await into(vehicleCosts).insertOnConflictUpdate(cost);
    await into(ledgerEntries).insertOnConflictUpdate(ledger);
  });

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

  Future<void> savePreferences(UserPreferencesCompanion value) =>
      into(userPreferences).insertOnConflictUpdate(value);
}

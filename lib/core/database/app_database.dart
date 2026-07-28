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
  // is the dividend per share and month; every projection starts from it.
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
  int get schemaVersion => 2;

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

  Stream<List<Account>> watchAccounts(String userId) =>
      (select(accounts)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.label)]))
          .watch();

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

  Future<void> saveLedgerEntry(LedgerEntriesCompanion value) =>
      into(ledgerEntries).insertOnConflictUpdate(value);

  Future<void> saveLedgerEntries(Iterable<LedgerEntriesCompanion> values) =>
      transaction(() async {
        for (final value in values) {
          await into(ledgerEntries).insertOnConflictUpdate(value);
        }
      });

  Future<void> deleteLedgerEntry(String id, String userId) =>
      (update(
        ledgerEntries,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        LedgerEntriesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> deleteLedgerSeries(String recurrenceId, String userId) =>
      (update(ledgerEntries)..where(
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

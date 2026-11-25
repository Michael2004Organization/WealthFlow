import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';

const _userId = 'owner';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 11, 1);

  Future<MasterDataData> entry(String kind, String value) async =>
      (await database.watchMasterData(_userId).first).firstWhere(
        (item) => item.kind == kind && item.value == value,
      );

  Future<List<String>> values(String kind) async => [
    for (final item in await database.watchMasterData(_userId).first)
      if (item.kind == kind) item.value,
  ];

  Future<void> booking(String id, String category, {String merchant = ''}) =>
      database.saveLedgerEntries([
        LedgerEntriesCompanion.insert(
          id: id,
          userId: _userId,
          bookingDate: now,
          amount: 10,
          category: category,
          merchant: Value(merchant),
          createdAt: now,
          updatedAt: now,
        ),
      ]);

  Future<void> budget(String id, String category) => database
      .into(database.categoryBudgets)
      .insert(
        CategoryBudgetsCompanion.insert(
          id: id,
          userId: _userId,
          category: category,
          monthlyLimit: 100,
          startMonth: DateTime(2026, 11),
          createdAt: now,
          updatedAt: now,
        ),
      );

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
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
  });

  tearDown(() => database.close());

  test('adding rejects duplicates ignoring case', () async {
    expect(await database.addMasterDatum(_userId, 'merchant', 'Rewe'), isTrue);
    expect(
      await database.addMasterDatum(_userId, 'merchant', 'rewe '),
      isFalse,
    );
    expect(await database.addMasterDatum(_userId, 'merchant', '  '), isFalse);
    expect(await values('merchant'), ['Rewe']);
  });

  test('a deleted entry can be added again and restored', () async {
    await database.addMasterDatum(_userId, 'merchant', 'Aldi');
    final aldi = await entry('merchant', 'Aldi');
    await database.deleteMasterDatum(aldi.id, _userId);
    expect(await values('merchant'), isEmpty);

    expect(await database.addMasterDatum(_userId, 'merchant', 'Aldi'), isTrue);
    expect(await values('merchant'), ['Aldi']);

    await database.deleteMasterDatum(aldi.id, _userId);
    await database.restoreMasterDatum(aldi.id, _userId);
    expect(await values('merchant'), ['Aldi']);
  });

  test(
    'usage counts bookings, also for values missing from the list',
    () async {
      await database.addMasterDatum(_userId, 'category', 'Essen');
      await booking('a', 'Essen', merchant: 'Rewe');
      await booking('b', 'Essen', merchant: 'Rewe');
      await booking('c', 'Kino');
      await budget('budget', 'Essen');

      final usage = await database.masterDataUsage(_userId);
      expect(usage['category']!['Essen']!.household, 3);
      expect(usage['category']!['Kino']!.total, 1);
      expect(usage['merchant']!['Rewe']!.total, 2);
    },
  );

  test('rename carries over to bookings and budgets', () async {
    await database.addMasterDatum(_userId, 'category', 'Essen');
    await booking('a', 'Essen');
    await booking('b', 'Essen');
    await booking('c', 'Auto');
    await budget('budget', 'Essen');

    final changed = await database.renameMasterDatum(
      await entry('category', 'Essen'),
      'Lebensmittel',
    );

    expect(changed, 3);
    expect(await values('category'), ['Lebensmittel']);
    final entries = await database.watchLedgerEntries(_userId).first;
    expect(entries.map((e) => e.category).toList()..sort(), [
      'Auto',
      'Lebensmittel',
      'Lebensmittel',
    ]);
    final budgets = await database.select(database.categoryBudgets).get();
    expect(budgets.single.category, 'Lebensmittel');
  });

  test('renaming to an existing name merges and keeps one budget', () async {
    await database.addMasterDatum(_userId, 'category', 'Essen');
    await database.addMasterDatum(_userId, 'category', 'Lebensmittel');
    await booking('a', 'Essen');
    await booking('b', 'Lebensmittel');
    await budget('old', 'Essen');
    await budget('kept', 'Lebensmittel');

    await database.renameMasterDatum(
      await entry('category', 'Essen'),
      'lebensmittel',
    );

    expect(await values('category'), ['Lebensmittel']);
    final entries = await database.watchLedgerEntries(_userId).first;
    expect(entries.every((e) => e.category == 'Lebensmittel'), isTrue);
    final active = await (database.select(
      database.categoryBudgets,
    )..where((row) => row.deletedAt.isNull())).get();
    expect(active.single.id, 'kept');
  });
}

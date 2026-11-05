import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/standing_order_schedule.dart';

final _now = DateTime.utc(2026, 1, 1);

Future<void> _setUp(AppDatabase database, String userId) async {
  await database.createUser(
    UsersCompanion.insert(
      id: userId,
      email: '$userId@example.test',
      displayName: userId,
      passwordHash: 'hash',
      passwordSalt: 'salt',
      createdAt: _now,
      updatedAt: _now,
    ),
  );
  await database.savePreferences(
    UserPreferencesCompanion.insert(userId: userId, updatedAt: _now),
  );
  for (final id in ['giro', 'depot']) {
    await database.saveAccount(
      AccountsCompanion.insert(
        id: id,
        userId: userId,
        bankName: 'Bank',
        label: id,
        balance: const Value(1000),
        availableBalance: const Value(1000),
        createdAt: _now,
        updatedAt: _now,
      ),
    );
  }
}

StandingOrdersCompanion _order(
  String userId, {
  String kind = 'expense',
  String target = '',
  int day = 1,
  String interval = 'monthly',
  DateTime? start,
}) => StandingOrdersCompanion.insert(
  id: 'miete',
  userId: userId,
  accountId: 'giro',
  targetAccountId: Value(target),
  kind: Value(kind),
  amount: 100,
  category: const Value('Wohnen'),
  merchant: const Value('Vermieter'),
  interval: Value(interval),
  dayOfMonth: day,
  startDate: start ?? DateTime(2026, 9, 1),
  createdAt: _now,
  updatedAt: _now,
);

Future<double> _balance(AppDatabase database, String id) async =>
    (await (database.select(
      database.accounts,
    )..where((row) => row.id.equals(id))).getSingle()).balance;

Future<List<LedgerEntry>> _entries(AppDatabase database) =>
    (database.select(database.ledgerEntries)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .get();

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Fälligkeiten', () {
    test('Tag 31 wird in kürzeren Monaten zum Monatsletzten', () {
      final dates = standingOrderDueDates(
        interval: 'monthly',
        dayOfMonth: 31,
        start: DateTime(2026, 1, 1),
        through: DateTime(2026, 4, 30),
      );
      expect(dates, [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 30),
      ]);
    });

    test('vierteljährlich ab dem ersten Termin nach dem Start', () {
      final dates = standingOrderDueDates(
        interval: 'quarterly',
        dayOfMonth: 15,
        start: DateTime(2026, 1, 20),
        through: DateTime(2026, 12, 31),
      );
      expect(dates, [
        DateTime(2026, 2, 15),
        DateTime(2026, 5, 15),
        DateTime(2026, 8, 15),
        DateTime(2026, 11, 15),
      ]);
    });

    test('nach dem Ende und vor dem letzten Termin nichts', () {
      final dates = standingOrderDueDates(
        interval: 'monthly',
        dayOfMonth: 1,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 5, 10),
        after: DateTime(2026, 3, 1),
        through: DateTime(2026, 12, 31),
      );
      expect(dates, [DateTime(2026, 4, 1), DateTime(2026, 5, 1)]);
      expect(
        nextStandingOrderDueDate(
          interval: 'yearly',
          dayOfMonth: 29,
          start: DateTime(2024, 2, 29),
          after: DateTime(2026, 3, 1),
        ),
        DateTime(2027, 2, 28),
      );
    });
  });

  group('Buchungen', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await _setUp(database, 'user');
    });

    tearDown(() => database.close());

    test('legt fällige Buchungen genau einmal an', () async {
      await database.into(database.standingOrders).insert(_order('user'));

      expect(
        await database.applyStandingOrders(
          'user',
          today: DateTime(2026, 11, 5),
        ),
        isTrue,
      );
      expect(
        await database.applyStandingOrders(
          'user',
          today: DateTime(2026, 11, 5),
        ),
        isFalse,
      );

      final entries = await _entries(database);
      expect(entries.map((entry) => entry.id), [
        'so-miete-20260901',
        'so-miete-20261001',
        'so-miete-20261101',
      ]);
      expect(entries.first.recurrenceId, 'miete');
      expect(await _balance(database, 'giro'), 700);
    });

    test('eine gelöschte Buchung kommt nicht wieder', () async {
      await database.into(database.standingOrders).insert(_order('user'));
      await database.applyStandingOrders('user', today: DateTime(2026, 9, 5));
      await database.deleteLedgerEntry('so-miete-20260901', 'user');
      // Even with the last due date lost, as after an older sync.
      await database
          .update(database.standingOrders)
          .write(const StandingOrdersCompanion(lastDueDate: Value(null)));

      await database.applyStandingOrders('user', today: DateTime(2026, 9, 5));

      expect(await _entries(database), isEmpty);
    });

    test('Sparen bucht beide Seiten', () async {
      await database
          .into(database.standingOrders)
          .insert(_order('user', kind: 'saving', target: 'depot'));

      await database.applyStandingOrders('user', today: DateTime(2026, 9, 1));

      final entries = await _entries(database);
      expect(entries.map((entry) => entry.id), [
        'so-miete-20260901',
        'so-miete-20260901-in',
      ]);
      expect(entries.map((entry) => entry.sourceId).toSet(), {
        'so-miete-20260901',
      });
      expect(await _balance(database, 'giro'), 900);
      expect(await _balance(database, 'depot'), 1100);
    });

    test('Serie wird zum Dauerauftrag', () async {
      final today = DateTime(2026, 11, 5);
      await database.saveLedgerEntries([
        for (var month = 9; month <= 14; month++)
          LedgerEntriesCompanion.insert(
            id: 'serie-$month',
            userId: 'user',
            bookingDate: DateTime(2026, month, 3),
            amount: 50,
            category: 'Abo',
            merchant: const Value('Streaming'),
            recurrenceId: const Value('serie'),
            accountId: const Value('giro'),
            createdAt: _now,
            updatedAt: _now,
          ),
      ]);

      final orderId = await database.convertSeriesToStandingOrder(
        'serie',
        'user',
        today: today,
      );

      final order = await (database.select(
        database.standingOrders,
      )..where((row) => row.id.equals(orderId))).getSingle();
      expect(order.dayOfMonth, 3);
      expect(order.amount, 50);
      expect(order.merchant, 'Streaming');
      expect(order.lastDueDate, DateTime(2026, 11, 3));
      // The three past bookings stay, the future ones are gone and nothing
      // was booked twice.
      expect((await _entries(database)).map((entry) => entry.id), [
        'serie-10',
        'serie-11',
        'serie-9',
      ]);
      expect(
        nextStandingOrderDueDate(
          interval: order.interval,
          dayOfMonth: order.dayOfMonth,
          start: order.startDate,
          after: today,
        ),
        DateTime(2026, 12, 3),
      );
    });
  });

  test('zwei Geräte buchen denselben Termin nur einmal', () async {
    final phone = AppDatabase.forTesting(NativeDatabase.memory());
    final laptop = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(phone.close);
    addTearDown(laptop.close);
    await _setUp(phone, 'user');
    await _setUp(laptop, 'user');
    Map<String, dynamic> wire(Map<String, Object?> data) =>
        Map<String, dynamic>.from(jsonDecode(jsonEncode(data)) as Map);

    await phone.into(phone.standingOrders).insert(_order('user'));
    await laptop.mergeUserData(
      'user',
      wire(await phone.exportUserData('user')),
    );
    // Both devices are offline on the due date and book it on their own.
    await phone.applyStandingOrders('user', today: DateTime(2026, 9, 2));
    await laptop.applyStandingOrders('user', today: DateTime(2026, 9, 2));
    await phone.mergeUserData(
      'user',
      wire(await laptop.exportUserData('user')),
    );
    await laptop.mergeUserData(
      'user',
      wire(await phone.exportUserData('user')),
    );

    for (final device in [phone, laptop]) {
      expect((await _entries(device)).map((entry) => entry.id), [
        'so-miete-20260901',
      ]);
      expect(await _balance(device, 'giro'), 900);
    }
  });
}

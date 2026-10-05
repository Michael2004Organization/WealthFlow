import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/features/household/household_page.dart';
import 'package:wealthflow_core/database/app_database.dart';

const _userId = 'household-user';

Future<AppDatabase> _database() async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final now = DateTime.utc(2026, 7, 1);
  await database.createUser(
    UsersCompanion.insert(
      id: _userId,
      email: 'household@example.test',
      displayName: 'Haushalt',
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
      id: 'giro',
      userId: _userId,
      bankName: 'Testbank',
      label: 'Giro',
      balance: const Value(1000),
      usageType: const Value('household'),
      createdAt: now,
      updatedAt: now,
    ),
  );
  return database;
}

LedgerEntriesCompanion _entry(String id, {String merchant = 'Rewe'}) {
  final now = DateTime.utc(2026, 7, 1);
  return LedgerEntriesCompanion.insert(
    id: id,
    userId: _userId,
    bookingDate: DateTime(2026, 7, 1),
    amount: 50,
    category: 'Einkaufen',
    merchant: Value(merchant),
    paymentMethod: const Value('EC-Karte'),
    accountId: const Value('giro'),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('restoring a deleted entry applies it to the account again', () async {
    final database = await _database();
    addTearDown(database.close);
    Future<double> balance() async =>
        (await database.watchAccounts(_userId).first).single.balance;

    await database.saveLedgerEntries([_entry('e1')]);
    expect(await balance(), 950);
    final saved = (await database.watchLedgerEntries(_userId).first).single;

    await database.deleteLedgerEntry('e1', _userId);
    expect(await balance(), 1000);
    expect(await database.watchLedgerEntries(_userId).first, isEmpty);

    await database.restoreLedgerEntries([saved]);
    expect(await balance(), 950);
    expect(await database.watchLedgerEntries(_userId).first, hasLength(1));
  });

  Future<AppDatabase> pumpHousehold(
    WidgetTester tester,
    Size size, {
    Future<void> Function(AppDatabase database)? seed,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = (await tester.runAsync(_database))!;
    await tester.runAsync(
      () => database.saveLedgerEntries([_entry('previous')]),
    );
    if (seed != null) await tester.runAsync(() => seed(database));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentUserIdProvider.overrideWithValue(_userId),
        ],
        child: const MaterialApp(home: Scaffold(body: HouseholdPage())),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    return database;
  }

  for (final size in [const Size(360, 800), const Size(1280, 900)]) {
    testWidgets('save and next keeps the editor open at $size', (tester) async {
      final database = await pumpHousehold(tester, size);

      await tester.tap(find.text('Buchung').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Betrag *'),
        '1.234,56',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Händler / Quelle'),
        'rewe',
      );
      await tester.pump();
      expect(
        find.widgetWithText(TextFormField, 'Einkaufen'),
        findsOneWidget,
        reason: 'category is suggested from the previous Rewe booking',
      );

      await tester.tap(find.text('Speichern & nächste'));
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.textContaining('Gespeichert: rewe'), findsOneWidget);
      expect(find.text('Weitere Optionen'), findsOneWidget);
      final saved = (await tester.runAsync(
        () => database.watchLedgerEntries(_userId).first,
      ))!;
      expect(saved.map((entry) => entry.amount), contains(1234.56));
      expect(
        saved.firstWhere((entry) => entry.amount == 1234.56).category,
        'Einkaufen',
      );
      expect(tester.takeException(), isNull);
      await tester.runAsync(database.close);
    });
  }
  testWidgets('editing one side of a transfer updates both sides', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 7, 1);
    final database = await pumpHousehold(
      tester,
      const Size(1280, 900),
      seed: (database) async {
        await database.saveAccount(
          AccountsCompanion.insert(
            id: 'tagesgeld',
            userId: _userId,
            bankName: 'Testbank',
            label: 'Tagesgeld',
            balance: const Value(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
        await database.saveLedgerEntries([
          for (final income in [false, true])
            LedgerEntriesCompanion.insert(
              id: income ? 'transfer-in' : 'transfer-out',
              userId: _userId,
              // The page opens on the current month.
              bookingDate: DateTime.now(),
              amount: 200,
              isIncome: Value(income),
              category: 'Umbuchung',
              merchant: const Value('Umbuchung Tagesgeld'),
              sourceType: const Value('transfer'),
              sourceId: const Value('transfer-1'),
              accountId: Value(income ? 'tagesgeld' : 'giro'),
              createdAt: now,
              updatedAt: now,
            ),
        ]);
      },
    );

    await tester.tap(find.text('Umbuchung Tagesgeld'));
    await tester.pumpAndSettle();
    expect(find.text('Buchung bearbeiten'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Betrag *'),
      '250',
    );
    await tester.tap(find.text('Speichern'));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();

    final entries = (await tester.runAsync(
      () => database.watchLedgerEntries(_userId).first,
    ))!;
    final legs = {
      for (final entry in entries.where((e) => e.sourceId == 'transfer-1'))
        entry.id: entry,
    };
    expect(legs['transfer-out']!.amount, 250);
    expect(legs['transfer-out']!.isIncome, isFalse);
    expect(legs['transfer-in']!.amount, 250);
    expect(legs['transfer-in']!.isIncome, isTrue);
    final balances = {
      for (final account in (await tester.runAsync(
        () => database.watchAccounts(_userId).first,
      ))!)
        account.id: account.balance,
    };
    // 1000 start, 50 from the earlier booking, 250 moved out.
    expect(balances['giro'], 700);
    expect(balances['tagesgeld'], 250);
    expect(tester.takeException(), isNull);
    await tester.runAsync(database.close);
  });
}
